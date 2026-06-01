import argparse
import base64
import json
import os
from pathlib import Path
from typing import Any, Dict, List, Optional


try:
    import yaml  # type: ignore
except Exception as exc:  # pragma: no cover
    raise SystemExit("Missing dependency PyYAML. Install with: pip install pyyaml requests") from exc

try:
    import requests  # type: ignore
except Exception as exc:  # pragma: no cover
    raise SystemExit("Missing dependency requests. Install with: pip install requests") from exc


def _load_config(path: Path) -> Dict[str, Any]:
    if not path.exists():
        raise SystemExit(f"Config file not found: {path}")
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise SystemExit("Invalid config format. Expected YAML object at root.")
    return data


def _env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        raise SystemExit(f"Missing required env var: {name}")
    return value


def _adf(text: str) -> Dict[str, Any]:
    return {
        "type": "doc",
        "version": 1,
        "content": [{"type": "paragraph", "content": [{"type": "text", "text": text}]}],
    }


TEAM = {
    "dt solutions": "61d3d6500586a20069465469",
    "dts": "61d3d6500586a20069465469",
    "yo": "61d3d6500586a20069465469",
    "erik calderon": "557058:0239b0a8-451b-48a5-ac22-a06111f5b8a5",
    "erik": "557058:0239b0a8-451b-48a5-ac22-a06111f5b8a5",
    "roberto melgar": "5ba9121d08ff0878b1b8ac80",
    "roberto": "5ba9121d08ff0878b1b8ac80",
    "axel palala": "5ba911e4b9665979c5587b41",
    "axel": "5ba911e4b9665979c5587b41",
    "jaroslav pospichal": "5ba911ff165d986a7c5294ae",
    "jaroslav": "5ba911ff165d986a7c5294ae",
    "carolina fuentes": "557058:88d97c4b-ebd7-46b2-b194-74de23f1613d",
    "carolina": "557058:88d97c4b-ebd7-46b2-b194-74de23f1613d",
    "efren gustavo buch": "61d4671fe67ea2006bcb5963",
    "efren": "61d4671fe67ea2006bcb5963",
    "anderly teleguario": "61d4671ce67ea2006bcb5940",
    "anderly": "61d4671ce67ea2006bcb5940",
    "kelvyn magzul": "61d4671b7aa7ac0070296608",
    "kelvyn": "61d4671b7aa7ac0070296608",
    "jonatan santiago": "712020:f1b7f989-706d-47b1-8d74-8105f428a512",
    "jonatan": "712020:f1b7f989-706d-47b1-8d74-8105f428a512",
    "marcela álvarez": "712020:ef404ed6-74ac-4ee5-8f1f-883880e49f44",
    "marcela": "712020:ef404ed6-74ac-4ee5-8f1f-883880e49f44",
    "maría lorena gonzález": "712020:cd1a2391-b582-4b08-91f0-e18d0423dd7d",
    "lorena": "712020:cd1a2391-b582-4b08-91f0-e18d0423dd7d",
    "juan carlos correa": "712020:bd63e11f-74e4-49b4-a9a5-00f1b7a6c4d2",
    "juan carlos": "712020:bd63e11f-74e4-49b4-a9a5-00f1b7a6c4d2",
    "melvin cojti": "712020:0f298b96-ecde-434e-9a74-e8da1eb3e5f2",
    "melvin": "712020:0f298b96-ecde-434e-9a74-e8da1eb3e5f2",
    "melvyn": "63496653db32d9ce175dc139",
    "martin n. ocampo": "712020:1408b1ac-beed-4a9e-98b0-250d36dd8e37",
    "martin": "712020:1408b1ac-beed-4a9e-98b0-250d36dd8e37",
    "abigail gaytan": "712020:5d0afccf-1b47-4cc7-ac27-39671948667a",
    "abigail": "712020:5d0afccf-1b47-4cc7-ac27-39671948667a",
}


class JiraPortableClient:
    def __init__(self, config: Dict[str, Any]) -> None:
        self.config = config
        self.base_url = _env("JIRA_URL").rstrip("/")
        self.email = _env("JIRA_EMAIL")
        self.token = _env("JIRA_TOKEN")
        self.account_id = _env("JIRA_ACCOUNT_ID")

        auth = base64.b64encode(f"{self.email}:{self.token}".encode("utf-8")).decode("utf-8")
        self.headers = {
            "Authorization": f"Basic {auth}",
            "Content-Type": "application/json",
        }
        project = self.config.get("project", {})
        self.project_key = project.get("key", "")
        self.board_id = project.get("board_id")
        self.prefix = project.get("prefix_summary", "Codex:")
        self.epic_default_key = project.get("epic_default_key")
        self.assignee_default = project.get("assignee_default", "dts")

    def _request(self, method: str, path: str, payload: Optional[Dict[str, Any]] = None,
                 params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        url = f"{self.base_url}{path}"
        resp = requests.request(method, url, headers=self.headers, json=payload, params=params, timeout=45)
        if not resp.ok:
            raise SystemExit(f"Jira API error {resp.status_code}: {resp.text}")
        if resp.text.strip():
            return resp.json()
        return {}

    def create_issue(self, summary: str, description: str, issue_type_id: str,
                     epic_key: Optional[str] = None, assignee_alias: Optional[str] = None) -> str:
        account_id = self.resolve_persona(assignee_alias or self.assignee_default)
        fields = {
            "project": {"key": self.project_key},
            "summary": f"{self.prefix} {summary}".strip(),
            "description": _adf(description),
            "issuetype": {"id": issue_type_id},
        }
        if account_id:
            fields["assignee"] = {"accountId": account_id}
        data = self._request("POST", "/rest/api/3/issue", payload={"fields": fields})
        key = data["key"]
        if epic_key:
            self.assign_to_epic([key], epic_key)
        return key

    def comment(self, issue_key: str, text: str) -> None:
        self._request(
            "POST",
            f"/rest/api/3/issue/{issue_key}/comment",
            payload={"body": _adf(text)},
        )

    def transition(self, issue_key: str, target_status_id: str) -> str:
        data = self._request("GET", f"/rest/api/3/issue/{issue_key}/transitions")
        transitions = data.get("transitions", [])
        selected = None
        for trans in transitions:
            if trans.get("to", {}).get("id") == target_status_id:
                selected = trans
                break
        if selected is None:
            raise SystemExit(f"No transition found for status id {target_status_id} in {issue_key}")
        self._request(
            "POST",
            f"/rest/api/3/issue/{issue_key}/transitions",
            payload={"transition": {"id": selected["id"]}},
        )
        return selected["to"]["name"]

    def list_epics(self) -> List[Dict[str, Any]]:
        jql = f"project = {self.project_key} AND issuetype = Epic AND statusCategory != Done ORDER BY created DESC"
        data = self._request(
            "GET",
            "/rest/api/3/search",
            params={"jql": jql, "fields": "summary,status", "maxResults": 50},
        )
        return data.get("issues", [])

    def assign_to_epic(self, issue_keys: List[str], epic_key: str) -> None:
        self._request(
            "POST",
            f"/rest/agile/1.0/epic/{epic_key}/issue",
            payload={"issues": issue_keys},
        )

    def active_sprint(self) -> Optional[Dict[str, Any]]:
        data = self._request("GET", f"/rest/agile/1.0/board/{self.board_id}/sprint", params={"state": "active"})
        values = data.get("values", [])
        return values[0] if values else None

    def move_to_sprint(self, issue_keys: List[str], sprint_id: int) -> None:
        self._request(
            "POST",
            f"/rest/agile/1.0/sprint/{sprint_id}/issue",
            payload={"issues": issue_keys},
        )

    def resolve_persona(self, persona: str) -> str:
        key = persona.strip().lower()
        if key in TEAM:
            return TEAM[key]
        data = self._request("GET", "/rest/api/3/user/search", params={"query": persona, "maxResults": 5})
        if data:
            return data[0]["accountId"]
        raise SystemExit(f"No user found in Jira for: {persona}")

    def assign_issue(self, issue_key: str, persona: str) -> str:
        account_id = self.resolve_persona(persona)
        self._request("PUT", f"/rest/api/3/issue/{issue_key}/assignee", payload={"accountId": account_id})
        return account_id

    def update_issue_fields(
        self,
        issue_key: str,
        description: Optional[str] = None,
        start_date: Optional[str] = None,
        due_date: Optional[str] = None,
        story_points: Optional[float] = None,
        priority_name: Optional[str] = None,
        labels: Optional[List[str]] = None,
    ) -> None:
        fields: Dict[str, Any] = {}
        if description:
            fields["description"] = _adf(description)
        if start_date:
            fields["customfield_10015"] = start_date
        if due_date:
            fields["duedate"] = due_date
        if story_points is not None:
            fields["customfield_10016"] = story_points
        if priority_name:
            fields["priority"] = {"name": priority_name}
        if labels:
            fields["labels"] = labels
        if not fields:
            raise SystemExit("No fields to update.")
        self._request("PUT", f"/rest/api/3/issue/{issue_key}", payload={"fields": fields})

    def log_work(self, issue_key: str, time_spent: str, comment: Optional[str] = None) -> None:
        payload: Dict[str, Any] = {"timeSpent": time_spent}
        if comment:
            payload["comment"] = _adf(comment)
        self._request("POST", f"/rest/api/3/issue/{issue_key}/worklog", payload=payload)


def _print_json(obj: Any) -> None:
    print(json.dumps(obj, ensure_ascii=False, indent=2))


def main() -> None:
    parser = argparse.ArgumentParser(description="Portable Jira helper for Codex projects.")
    parser.add_argument("--config", default="project.jira.config.yml",
                        help="Path to project jira config YAML.")

    sub = parser.add_subparsers(dest="cmd", required=True)

    create_issue = sub.add_parser("create-issue")
    create_issue.add_argument("--summary", required=True)
    create_issue.add_argument("--description", required=True)
    create_issue.add_argument("--type-id", required=True, help="Issue type id (e.g. 10017)")
    create_issue.add_argument("--epic-key", default="")
    create_issue.add_argument("--assignee", default="", help="Human alias: erik, dts, axel...")

    comment = sub.add_parser("comment")
    comment.add_argument("--issue-key", required=True)
    comment.add_argument("--text", required=True)

    trans = sub.add_parser("transition")
    trans.add_argument("--issue-key", required=True)
    trans.add_argument("--status-id", required=True)

    sub.add_parser("list-epics")
    sub.add_parser("active-sprint")

    sprint = sub.add_parser("move-to-sprint")
    sprint.add_argument("--issue-keys", required=True, help="Comma-separated keys: ROAD-1,ROAD-2")
    sprint.add_argument("--sprint-id", required=True, type=int)

    assign = sub.add_parser("assign-issue")
    assign.add_argument("--issue-key", required=True)
    assign.add_argument("--assignee", required=True, help="Human alias: erik, dts, axel...")

    update_issue = sub.add_parser("update-issue")
    update_issue.add_argument("--issue-key", required=True)
    update_issue.add_argument("--description", default="")
    update_issue.add_argument("--start-date", default="")
    update_issue.add_argument("--due-date", default="")
    update_issue.add_argument("--story-points", type=float)
    update_issue.add_argument("--priority", default="")
    update_issue.add_argument("--labels", default="", help="Comma-separated labels")

    log_work = sub.add_parser("log-work")
    log_work.add_argument("--issue-key", required=True)
    log_work.add_argument("--time-spent", required=True, help="Jira format: 2h, 30m, 1h 30m, 1d")
    log_work.add_argument("--comment", default="")

    update_full = sub.add_parser("update-full")
    update_full.add_argument("--issue-key", required=True)
    update_full.add_argument("--description", default="")
    update_full.add_argument("--start-date", default="")
    update_full.add_argument("--due-date", default="")
    update_full.add_argument("--story-points", type=float)
    update_full.add_argument("--priority", default="")
    update_full.add_argument("--labels", default="", help="Comma-separated labels")
    update_full.add_argument("--time-spent", default="", help="Jira format: 2h, 30m, 1h 30m, 1d")
    update_full.add_argument("--work-comment", default="")

    args = parser.parse_args()

    cfg = _load_config(Path(args.config))
    jira = JiraPortableClient(cfg)

    if args.cmd == "create-issue":
        key = jira.create_issue(args.summary, args.description, args.type_id, args.epic_key or None, args.assignee or None)
        print(f"Created: {key}")
        return

    if args.cmd == "comment":
        jira.comment(args.issue_key, args.text)
        print(f"Commented: {args.issue_key}")
        return

    if args.cmd == "transition":
        to_name = jira.transition(args.issue_key, args.status_id)
        print(f"Transitioned {args.issue_key} -> {to_name}")
        return

    if args.cmd == "list-epics":
        epics = jira.list_epics()
        simple = [{"key": e["key"], "summary": e["fields"]["summary"], "status": e["fields"]["status"]["name"]} for e in epics]
        _print_json(simple)
        return

    if args.cmd == "active-sprint":
        sprint = jira.active_sprint()
        _print_json(sprint or {})
        return

    if args.cmd == "move-to-sprint":
        keys = [x.strip() for x in args.issue_keys.split(",") if x.strip()]
        jira.move_to_sprint(keys, args.sprint_id)
        print(f"Moved {len(keys)} issues to sprint {args.sprint_id}")
        return

    if args.cmd == "assign-issue":
        acc = jira.assign_issue(args.issue_key, args.assignee)
        print(f"Assigned: {args.issue_key} -> {args.assignee} ({acc})")
        return

    if args.cmd == "update-issue":
        labels = [x.strip() for x in args.labels.split(",") if x.strip()] if args.labels else None
        jira.update_issue_fields(
            issue_key=args.issue_key,
            description=args.description or None,
            start_date=args.start_date or None,
            due_date=args.due_date or None,
            story_points=args.story_points,
            priority_name=args.priority or None,
            labels=labels,
        )
        print(f"Updated fields: {args.issue_key}")
        return

    if args.cmd == "log-work":
        jira.log_work(args.issue_key, args.time_spent, args.comment or None)
        print(f"Logged work: {args.issue_key} ({args.time_spent})")
        return

    if args.cmd == "update-full":
        labels = [x.strip() for x in args.labels.split(",") if x.strip()] if args.labels else None
        jira.update_issue_fields(
            issue_key=args.issue_key,
            description=args.description or None,
            start_date=args.start_date or None,
            due_date=args.due_date or None,
            story_points=args.story_points,
            priority_name=args.priority or None,
            labels=labels,
        )
        if args.time_spent:
            jira.log_work(args.issue_key, args.time_spent, args.work_comment or None)
        print(f"Updated full: {args.issue_key}")
        return

    raise SystemExit(f"Unsupported command: {args.cmd}")


if __name__ == "__main__":
    main()
