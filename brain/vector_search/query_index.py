from __future__ import annotations

import argparse
import json
import math
import re
from collections import Counter
from pathlib import Path


TOKEN_RE = re.compile(r"[A-Za-z0-9_]+", re.UNICODE)


def normalize(text: str) -> list[str]:
    return [t.lower() for t in TOKEN_RE.findall(text)]


def cosine(a: list[float], b: list[float]) -> float:
    dot = sum(x * y for x, y in zip(a, b))
    na = math.sqrt(sum(x * x for x in a))
    nb = math.sqrt(sum(y * y for y in b))
    if na == 0 or nb == 0:
        return 0.0
    return dot / (na * nb)


def vectorize(tokens: list[str], vocab_index: dict[str, int]) -> list[float]:
    counts = Counter(tokens)
    vec = [0.0] * len(vocab_index)
    total = sum(counts.values()) or 1
    for token, count in counts.items():
        idx = vocab_index.get(token)
        if idx is not None:
            vec[idx] = count / total
    return vec


def try_import_embeddings():
    try:
        from sentence_transformers import SentenceTransformer  # type: ignore
        return SentenceTransformer
    except Exception:
        return None


def main() -> None:
    parser = argparse.ArgumentParser(description="Consulta indice vectorial local del brain.")
    parser.add_argument("query", help="Texto de busqueda.")
    parser.add_argument("--index", default=str(Path(__file__).resolve().parent / "indexes" / "brain_semantic_index.json"))
    parser.add_argument("--top", type=int, default=5)
    parser.add_argument("--model", default="sentence-transformers/all-MiniLM-L6-v2", help="Modelo para embeddings si el indice esta en modo embeddings.")
    args = parser.parse_args()

    index_path = Path(args.index)
    data = json.loads(index_path.read_text(encoding="utf-8"))
    mode = data.get("mode", "local")

    if mode == "embeddings":
        SentenceTransformer = try_import_embeddings()
        if SentenceTransformer is None:
            raise SystemExit("El indice esta en modo embeddings pero faltan dependencias. Instala sentence-transformers o reconstruye con --mode local.")
        model_name = data.get("model") or args.model
        model = SentenceTransformer(model_name)
        qvec = model.encode([args.query], normalize_embeddings=True)[0].tolist()
    else:
        vocab = data["vocabulary"]
        vocab_index = {token: idx for idx, token in enumerate(vocab)}
        qvec = vectorize(normalize(args.query), vocab_index)

    scored = []
    for doc in data["vectors"]:
        score = cosine(qvec, doc["vector"])
        if score > 0:
            scored.append((score, doc))

    scored.sort(key=lambda item: item[0], reverse=True)

    if not scored:
        print("Sin coincidencias fuertes.")
        return

    for score, doc in scored[: args.top]:
        print(f"{score:.3f} | {doc['path']} | {doc['title']} ({doc['kind']})")


if __name__ == "__main__":
    main()
