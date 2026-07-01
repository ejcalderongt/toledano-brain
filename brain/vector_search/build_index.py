from __future__ import annotations

import argparse
import json
import math
import os
import re
from collections import Counter, defaultdict
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Iterable


TOKEN_RE = re.compile(r"[A-Za-z0-9_]+", re.UNICODE)


@dataclass
class DocRecord:
    path: str
    title: str
    kind: str
    text: str
    tokens: list[str]


def normalize(text: str) -> list[str]:
    return [t.lower() for t in TOKEN_RE.findall(text)]


def iter_source_files(root: Path) -> Iterable[Path]:
    include_ext = {".md", ".yml", ".yaml", ".json"}
    for path in root.rglob("*"):
        if path.is_file() and path.suffix.lower() in include_ext:
            if "brain\\vector_search\\indexes" in str(path).replace("/", "\\"):
                continue
            yield path


def load_text(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="cp1252", errors="ignore")


def build_docs(root: Path) -> list[DocRecord]:
    docs: list[DocRecord] = []
    for path in iter_source_files(root):
        text = load_text(path)
        title = path.stem
        if path.suffix.lower() in {".md"}:
            first_line = next((line.strip("# ").strip() for line in text.splitlines() if line.strip()), path.stem)
            title = first_line[:120]
            kind = "markdown"
        elif path.suffix.lower() in {".yml", ".yaml"}:
            kind = "yaml"
        else:
            kind = "json"

        docs.append(DocRecord(
            path=str(path.relative_to(root)).replace("\\", "/"),
            title=title,
            kind=kind,
            text=text,
            tokens=normalize(text),
        ))
    return docs


def build_vocabulary(docs: list[DocRecord], min_df: int = 2) -> list[str]:
    df = Counter()
    for doc in docs:
        df.update(set(doc.tokens))
    return sorted([token for token, count in df.items() if count >= min_df])


def vectorize(tokens: list[str], vocab_index: dict[str, int]) -> list[float]:
    counts = Counter(tokens)
    vec = [0.0] * len(vocab_index)
    total = sum(counts.values()) or 1
    for token, count in counts.items():
        idx = vocab_index.get(token)
        if idx is not None:
            vec[idx] = count / total
    return vec


def cosine(a: list[float], b: list[float]) -> float:
    dot = sum(x * y for x, y in zip(a, b))
    na = math.sqrt(sum(x * x for x in a))
    nb = math.sqrt(sum(y * y for y in b))
    if na == 0 or nb == 0:
        return 0.0
    return dot / (na * nb)


def main() -> None:
    parser = argparse.ArgumentParser(description="Construye indice vectorial local del brain.")
    parser.add_argument("--root", default=str(Path(__file__).resolve().parents[2]), help="Ruta raiz del repo.")
    parser.add_argument("--output", default=str(Path(__file__).resolve().parent / "indexes" / "brain_semantic_index.json"), help="Archivo de salida.")
    args = parser.parse_args()

    root = Path(args.root)
    docs = build_docs(root)
    vocab = build_vocabulary(docs, min_df=2)
    vocab_index = {token: idx for idx, token in enumerate(vocab)}

    vectors = []
    for doc in docs:
        vectors.append({
            "path": doc.path,
            "title": doc.title,
            "kind": doc.kind,
            "vector": vectorize(doc.tokens, vocab_index),
        })

    payload = {
        "root": str(root),
        "documents": len(docs),
        "vocabulary_size": len(vocab),
        "vocabulary": vocab,
        "vectors": vectors,
    }

    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Indexado: {len(docs)} documentos -> {out_path}")


if __name__ == "__main__":
    main()
