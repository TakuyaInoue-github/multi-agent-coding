---
task_id: task-xxx
worker_type: coding
depends_on: []
parallel_ok: false
input_artifacts: []
output_artifacts: []
permissions:
  filesystem:
    write: []
    read: []
  execution:
    allowed: [build, lint, format, test]
    disallowed: [deploy, package_install]
  network:
    disallowed: [all]
required_packages: []
environment_verified: false
commander_reasoning: |
  （なぜこのタスクをこの粒度・依存関係で切ったかの根拠）
---

## 指示内容

（自然言語で明確に記述する）

## 期待する成果物

（output_artifacts に対応する具体的な期待内容）

## 注意事項

（前タスクからの申し送り・既知の制約）
