# PhysLit — Implementation Guide

**Product**: PhysLit — Physics Literacy Probe
**Type**: Research artifact (not a product). Open-source repo + GitHub Pages capability matrix.
**Stack**: Python 3.11+ · uv · pydantic · Jinja2 · GitHub Pages · GitHub Actions
**Repo**: `github.com/dongzhang84/physlit` (to be created, public)
**Last Updated**: 2026-05-04

> 这是一个研究项目的 implementation guide，不是产品的 launch 计划。
> **没有 backend、没有 web app、没有 auth、没有 DB、没有 Stripe**。
> 所有数据是 commit 进 repo 的 JSON 文件；所有展示是 GitHub Pages 静态站。
> Bootstrap 走 `bash stack/new-project.sh physlit "PhysLit"`（建 repo 骨架 + workflow + GitHub Pages 准备），然后按 Phase 0 手动加 Python 栈（uv init + 目录结构）。
> 业务逻辑和方法论在 [`ideas/physlit.md`](../ideas/physlit.md)。本文件只讲**怎么建**。

---

## ⚠️ Golden Rules

研究项目的可信度靠这五条。代码层面要把它们 enforce 住，不能只靠文档约定。

**Rule 1 — Pre-registration is irreversible.**
`predictions/v0_1_prereg.md` 一旦 commit + 打 git tag `prereg-v0.1-locked`，CI 验证它的 SHA-256 和 tag 时刻一致。任何修改要 version-tag (`prereg-v0.1.1-locked`) 并在 published results 里显式标注"deviation from prereg"。

**Rule 2 — Phenomenon generators must be deterministic where possible.**
v0.1 只用 Tier 1（Python 代码模拟器）+ Tier 3（手写 + 公开标记 "manual"）。**不用 Tier 2（AI 生成）**——避免 contamination 争议。架构留口子给 v0.5。

**Rule 3 — Every result is open verbatim.**
prompts 版本化、responses 全文、model 精确版本号、actual cost——全部 commit 进 `results/`。**不允许选择性发布**。

**Rule 4 — N=5 trials with fresh sessions is enforced in code.**
不是文档约定。`runners/base.py` 的 trial loop 必须每次新建 client + 新 conversation_id。代码层面 enforce，PR review 拒绝任何 multi-turn 节流方案。

**Rule 5 — Open-weight reproduction must work end-to-end.**
`replicate.sh <api_keys>` 从空 repo 起跑到 capability matrix，CI 每次 push 都跑这个。任何不可复现的中间步骤都是 bug，不是 feature。

---

## Phase 0 — Repo Scaffold

### 0.1 创建 repo 和 Python 环境

```bash
mkdir physlit && cd physlit
git init -b main

# uv 初始化（比 poetry 快、设置简单）
curl -LsSf https://astral.sh/uv/install.sh | sh   # 如未装
uv init --python 3.11
uv add anthropic openai google-genai pydantic pyyaml jinja2 click
uv add --dev pytest ruff mypy pre-commit
```

`pyproject.toml` 加几行：

```toml
[project]
name = "physlit"
version = "0.0.1"
description = "Physics Literacy Probe — diagnostic for LLM physics reasoning"
requires-python = ">=3.11"

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "B", "UP"]

[tool.mypy]
strict = true
python_version = "3.11"
```

### 0.2 目录结构

```
physlit/
├── README.md
├── METHODOLOGY.md            ← 拷自 ideas/physlit.md（保持同步）
├── PRODUCT_PLAN.md           ← 同上
├── LICENSE                   ← MIT
├── pyproject.toml
├── uv.lock
├── .python-version
├── .pre-commit-config.yaml
├── .gitignore
├── replicate.sh              ← Phase 11
│
├── src/physlit/              ← Python 包
│   ├── __init__.py
│   ├── schema/               ← Phase 1: pydantic models
│   ├── generators/           ← Phase 2-4: Tier 1/2/3
│   ├── runners/              ← Phase 6-7: 跑模型
│   ├── judges/               ← Phase 8: 双 LLM judge
│   ├── analysis/             ← Phase 9
│   └── site/                 ← Phase 10: Jinja2 渲染
│
├── frameworks/               ← 输入：每个 framework 一个目录
│   └── 01_aristotelian/
│
├── predictions/
│   └── v0_1_prereg.md        ← Phase 5: 预注册，git-tagged
│
├── prompts/                  ← 版本化的 prompt 模板
│   ├── stage1_induction.md
│   ├── stage2_formulation.md
│   ├── stage3_prediction.md
│   └── meta_question.md
│
├── results/                  ← 输出：所有模型 response
│   └── <model-version>/<framework>/<stage>/<trial>.json
│
├── analysis/                 ← 输出：计算后的报告
│   ├── v0_1_findings.md
│   ├── capability_matrix.json
│   └── cross_set_consistency.md
│
├── site/                     ← Phase 10: GitHub Pages 输出
│   ├── templates/
│   └── static/
│
├── scripts/
│   ├── replicate.sh
│   ├── lock_prereg.sh
│   ├── verify_prereg_integrity.py
│   └── extract-sprint-summary.py  ← 拷自 playbook stack/
│
├── tests/
│   └── test_*.py
│
└── .github/workflows/
    ├── ci.yml
    ├── deploy-site.yml
    ├── sprint-report.yml      ← 拷自 playbook stack/
    └── notify-playbook.yml    ← 拷自 playbook stack/
```

### 0.3 .gitignore

```gitignore
__pycache__/
*.py[cod]
.venv/
.python-version

.pytest_cache/
.mypy_cache/
.ruff_cache/

# secrets
.env
.env.local

# uv
# (uv.lock IS committed — don't ignore)

# generated site
site/build/

# OS
.DS_Store
```

### 0.4 .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.6.0
    hooks:
      - id: ruff
      - id: ruff-format
  - repo: local
    hooks:
      - id: verify-prereg
        name: Verify pre-registration integrity
        entry: python scripts/verify_prereg_integrity.py
        language: system
        files: ^predictions/.*\.md$
        pass_filenames: false
```

### 0.5 LICENSE

MIT for code, CC BY 4.0 for phenomenon sets and predictions. 创建两个文件：`LICENSE`（MIT 全文）和 `LICENSE-DATA`（CC BY 4.0）。README 注明分别适用范围。

---

## Phase 1 — Framework Spec Schema + Tier Decision Tree

### 1.1 Framework spec 是什么

每个 framework（Aristotelian / F=mv / 颜色力 / ...）有一个 **spec**——简短结构化描述。Spec 决定走哪一档 generator。

`src/physlit/schema/framework_spec.py`:

```python
from pydantic import BaseModel, Field
from typing import Literal

Tier = Literal["tier1_simulator", "tier2_ai", "tier3_manual"]
Category = Literal["A_historical", "B_counterfactual", "C_arbitrary"]

class FrameworkSpec(BaseModel):
    """The minimal description of a phenomenon framework.

    Tier 1 frameworks add a Python simulator module path.
    Tier 2 frameworks add a prose description for AI generation.
    Tier 3 frameworks reference manually-authored markdown files.
    """
    id: str = Field(pattern=r"^\d{2}_[a-z_]+$")    # e.g. "01_aristotelian"
    name: str                                       # "Aristotelian Mechanics"
    category: Category
    tier: Tier
    description: str                                # 1-2 paragraph framework summary
    rationale: str                                  # why this category, why this tier

    # Tier 1 only
    simulator_module: str | None = None             # e.g. "physlit.generators.tier1.f_equals_mv"

    # Tier 2 only (v0.5+; not used in v0.1)
    generation_prompt: str | None = None
    generator_model: str | None = None              # must be different family from tested models

    # Tier 3 only
    manual_authoring_note: str | None = None        # explanation of why no automation
```

### 1.2 Tier decision tree（必须记在文档里）

```
是否能用数学/代码精确描述这个 framework？
├─ 是 → Tier 1 (simulator)
│       例：F=mv, 反引力, 1/r 引力, 慢光, 能量衰减, 颜色力（数值规则）
│
├─ 部分能 → Tier 1 (核心) + Tier 3 (扩展现象)
│           例：颜色力世界（核心数值规则 Tier 1，但"红色物体的颜色变化"等 Tier 3）
│
└─ 否（纯概念性）→ Tier 3 v0.1 / Tier 2 v0.5
                  例：亚里士多德 "natural place"、燃素、Lamarckian 物理、
                      observer-dependent physics
```

**v0.1 范围**：所有 Category B（counterfactual self-consistent）走 Tier 1；Category A + 部分 Category C 走 Tier 3。**Tier 2 在 v0.1 不启用**。

### 1.3 第一个 framework 的 spec（Aristotelian, Tier 3 manual）

`frameworks/01_aristotelian/spec.yaml`:

```yaml
id: "01_aristotelian"
name: "Aristotelian Mechanics"
category: "A_historical"
tier: "tier3_manual"

description: |
  Pre-Newtonian framework: motion requires a sustained applied force,
  objects have a "natural place" they tend toward, heavier objects fall
  faster than lighter ones in the same medium, no concept of inertia.

rationale: |
  Cannot be cleanly coded — "natural place" is conceptual, not numeric.
  AI generation (Tier 2) deferred to v0.5 due to contamination risk
  between generator and tested model. Manual authorship for v0.1 with
  explicit "manual" flag on every observation.

manual_authoring_note: |
  Each observation reviewed by author + 1 external physics-trained reader
  before the prereg lock to reduce subjective bias.
```

### 1.4 Spec validator

`scripts/validate_specs.py`:

```python
"""Validate every frameworks/*/spec.yaml against the FrameworkSpec schema."""
import sys, yaml
from pathlib import Path
from physlit.schema.framework_spec import FrameworkSpec

def main():
    errors = []
    for spec_file in Path("frameworks").glob("*/spec.yaml"):
        try:
            data = yaml.safe_load(spec_file.read_text())
            FrameworkSpec.model_validate(data)
            print(f"[OK] {spec_file}")
        except Exception as e:
            errors.append((spec_file, e))
            print(f"[ERR] {spec_file}: {e}")
    sys.exit(1 if errors else 0)

if __name__ == "__main__":
    main()
```

CI 把它接进 `.github/workflows/ci.yml`（Phase 12）。

---

## Phase 2 — Tier 1 Simulator Framework

### 2.1 Simulator base class

`src/physlit/generators/tier1/base.py`:

```python
from abc import ABC, abstractmethod
from dataclasses import dataclass

@dataclass
class Observation:
    """A single observed phenomenon, plain language."""
    text: str
    deterministic_seed: int | None = None  # for reproducibility

@dataclass
class PredictionScenario:
    """A novel scenario for Stage 3 prediction."""
    text: str           # natural-language description given to the model
    init_state: dict    # internal: simulator's initial conditions

@dataclass
class GroundTruthPrediction:
    """The 'correct' prediction under the framework's own logic."""
    scenario_text: str
    framework_prediction: str   # what the framework predicts
    real_physics_prediction: str # what real physics predicts (to detect leakage)

class Tier1Simulator(ABC):
    """Deterministic Python simulator for a counterfactual framework."""

    @property
    @abstractmethod
    def framework_id(self) -> str: ...

    @abstractmethod
    def generate_observations(self, n: int = 12, seed: int = 42) -> list[Observation]:
        """Produce N observations consistent with the framework rules.

        Must be deterministic given the seed. No external API calls.
        """

    @abstractmethod
    def predict(self, scenario: PredictionScenario) -> GroundTruthPrediction:
        """Apply the framework's rules to a novel scenario."""

    def write_observations_md(self, output_path: str, n: int = 12) -> None:
        """Generate observations.md from the simulator output."""
        obs = self.generate_observations(n)
        md = "# Observations\n\n"
        md += "_Generated by Tier 1 simulator. Reproducible from seed._\n\n"
        for i, o in enumerate(obs, 1):
            md += f"{i}. {o.text}\n"
        Path(output_path).write_text(md)
```

### 2.2 第一个 Tier 1 simulator 示例：F=mv 世界

`src/physlit/generators/tier1/f_equals_mv.py`:

```python
"""F=mv world: force is proportional to velocity, not acceleration.

In this world:
- Push with force F → object moves at speed v = F/m
- Stop pushing → object stops immediately (no inertia)
- Double the force → double the speed
- Mass affects steady-state speed, not acceleration profile
"""
from .base import Tier1Simulator, Observation, PredictionScenario, GroundTruthPrediction

class FEqualsMVWorld(Tier1Simulator):
    @property
    def framework_id(self) -> str:
        return "06_f_equals_mv"

    def generate_observations(self, n: int = 12, seed: int = 42) -> list[Observation]:
        # Hand-crafted phenomena that follow F=mv consistently.
        # Each observation describes a setup + outcome in plain language,
        # without using force/mass/velocity vocabulary as theoretical terms.
        templates = [
            "A 1 kg cart is pushed with a steady 2 N force; it moves at 2 m/s. "
            "When the push stops, it halts immediately.",
            "Doubling the force on the same cart doubles its speed; halving "
            "it halves the speed. The change is instantaneous.",
            "A 2 kg cart pushed with 2 N moves at 1 m/s; the same force on a "
            "1 kg cart yields 2 m/s.",
            # ... 8-9 more, covering different aspects:
            #   - friction-free baseline
            #   - what happens when force is removed
            #   - relationship between mass and steady speed
            #   - composition of forces
            #   - work done over a distance (if applicable in this world)
        ]
        return [Observation(text=t, deterministic_seed=seed) for t in templates[:n]]

    def predict(self, scenario: PredictionScenario) -> GroundTruthPrediction:
        # Simulator computes the framework's prediction
        m = scenario.init_state["mass"]
        f = scenario.init_state["force"]
        v_framework = f / m  # F=mv
        a_real = f / m       # F=ma in real physics; result over time differs
        # (concrete framing depends on scenario type)
        return GroundTruthPrediction(
            scenario_text=scenario.text,
            framework_prediction=f"Object moves at {v_framework} m/s instantly when force applied.",
            real_physics_prediction=f"Object accelerates at {a_real} m/s² from rest.",
        )
```

### 2.3 Simulator 的确定性契约

每个 simulator 必须满足：

1. 同一 seed 下输出一致（不同机器、不同 Python 版本）
2. 不调用任何外部 API
3. 不依赖系统时间、随机源（除显式传入的 seed）
4. `pytest` 验证：跑两遍输出 byte-identical

`tests/test_simulators.py`:

```python
import pytest
from physlit.generators.tier1.f_equals_mv import FEqualsMVWorld

def test_determinism():
    sim = FEqualsMVWorld()
    out1 = sim.generate_observations(n=12, seed=42)
    out2 = sim.generate_observations(n=12, seed=42)
    assert [o.text for o in out1] == [o.text for o in out2]
```

---

## Phase 3 — Tier 2 AI Generator (Scaffold Only, Disabled in v0.1)

### 3.1 为什么留接口但不启用

v0.1 不用 AI 生成 phenomena（contamination 风险，`ideas/physlit.md §4.5` 没有 mitigation 完整方案）。但架构要预留——v0.5 的工作就是把这个 stub 实现。

### 3.2 Stub 接口

`src/physlit/generators/tier2/base.py`:

```python
from .base_protocol import GeneratorProtocol  # 共享接口

class Tier2AIGenerator(GeneratorProtocol):
    """AI-generated phenomena. DISABLED in v0.1.

    Architectural commitment for v0.5:
    - Generator model MUST be from a different family than any tested model
    - Sample audit by human required before phenomenon set is locked
    - Multiple-generator cross-validation: same spec → 3 generators → diff
    """
    def __init__(self):
        raise NotImplementedError(
            "Tier 2 AI generation is deferred to v0.5. "
            "v0.1 uses Tier 1 (simulator) + Tier 3 (manual) only. "
            "See ideas/physlit.md §4.5 for contamination concerns."
        )
```

CI 验证：`scripts/validate_specs.py` 在 v0.1 配置下检测到 `tier=tier2_ai` 直接报错。

---

## Phase 4 — Ground-Truth Predictor

### 4.1 Tier 1 frameworks 自动产出 ground truth

Phase 2 的 simulator 已经实现 `predict(scenario)` 方法。把它和 `prediction_scenarios.yaml` 配合：

`frameworks/06_f_equals_mv/prediction_scenarios.yaml`:

```yaml
scenarios:
  - id: "scenario_1"
    text: "A 3 kg block is pushed with constant 6 N force for 5 seconds. Describe its motion."
    init_state:
      mass: 3.0
      force: 6.0
      duration: 5.0
  - id: "scenario_2"
    text: "Two carts of equal mass are connected by a rigid rod. Force F is applied to one. What happens?"
    init_state:
      mass: 2.0
      force: 4.0
      coupled: true
  # ... 3 more
```

Generator script `scripts/generate_ground_truth.py`:

```python
"""For each Tier 1 framework, run its simulator over prediction_scenarios.yaml
and write ground_truth_predictions.md.

Tier 3 frameworks: ground_truth_predictions.md is hand-written by the author.
"""
import yaml, importlib
from pathlib import Path
from physlit.schema.framework_spec import FrameworkSpec

for spec_file in Path("frameworks").glob("*/spec.yaml"):
    spec = FrameworkSpec.model_validate(yaml.safe_load(spec_file.read_text()))
    if spec.tier != "tier1_simulator":
        continue
    sim_class = ...  # import via spec.simulator_module
    sim = sim_class()
    scenarios_yaml = spec_file.parent / "prediction_scenarios.yaml"
    output_md = spec_file.parent / "ground_truth_predictions.md"
    # iterate, predict, write...
```

### 4.2 Tier 3 frameworks 手写 ground truth

`frameworks/01_aristotelian/ground_truth_predictions.md` — 手写。每条预测包含：

- 场景描述
- 框架自身预测（如"按亚里士多德，重物落得快"）
- 真实物理预测（如"按现代物理，质量不影响自由落体"）
- 标记 `manual: <作者签名 + 日期>`

为什么需要"真实物理预测"那一列：判断 prediction 阶段时要检测模型是否"溜回真实物理"。这是一个二分判据。

---

## Phase 5 — Pre-Registration + Integrity Lock

### 5.1 Prereg 文件

`predictions/v0_1_prereg.md`：照 `ideas/physlit.md §3.3` 的 P1-P5 全文写进去 + 加 metadata header：

```markdown
# Pre-Registered Predictions for PhysLit v0.1

**Locked at commit**: <will be filled by lock_prereg.sh>
**Locked at git tag**: prereg-v0.1-locked
**Lock timestamp**: <UTC ISO-8601>
**SHA-256 of this file**: <will be computed by lock_prereg.sh>

> Once locked, this file MUST NOT be modified. Any change requires a new
> tag (prereg-v0.1.1-locked) and explicit "deviation from prereg" notice
> in published results.

## P1 — Induction failure under training-data conflict
[full text from ideas/physlit.md §3.3]

...
```

### 5.2 Lock 脚本

`scripts/lock_prereg.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

PREREG=predictions/v0_1_prereg.md
VERSION=${1:-v0.1}
TAG="prereg-${VERSION}-locked"

if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Tag $TAG already exists. Use a new version (e.g. v0.1.1)."
  exit 1
fi

# 计算 SHA-256 写进文件
HASH=$(sha256sum "$PREREG" | awk '{print $1}')
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# 把 metadata 替换到 header 里（手动确认，不要全自动改）
echo "About to lock $PREREG with:"
echo "  hash: $HASH"
echo "  timestamp: $TIMESTAMP"
echo "  tag: $TAG"
echo "Edit the file header manually with these values, then press Enter to continue."
read -r

git add "$PREREG"
git commit -m "lock: pre-register predictions for ${VERSION}"
git tag -a "$TAG" -m "Pre-registered predictions locked at $TIMESTAMP"
git push && git push --tags
```

### 5.3 完整性验证

`scripts/verify_prereg_integrity.py`:

```python
"""Verify that predictions/v0_1_prereg.md hasn't been modified since the lock tag.

Run by pre-commit hook AND by CI on every push.
"""
import hashlib, subprocess, sys, re
from pathlib import Path

PREREG = Path("predictions/v0_1_prereg.md")
TAG_PREFIX = "prereg-"

def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    text = PREREG.read_text()
    m = re.search(r"\*\*SHA-256 of this file\*\*: ([0-9a-f]{64})", text)
    if not m:
        print("ERROR: prereg file has no SHA-256 line. Run scripts/lock_prereg.sh first.")
        sys.exit(1)
    declared_hash = m.group(1)

    # Compute the hash of the file *with the SHA-256 line zeroed out*
    # (so the hash doesn't include itself)
    placeholder = "**SHA-256 of this file**: " + ("0" * 64)
    normalized = re.sub(r"\*\*SHA-256 of this file\*\*: [0-9a-f]{64}", placeholder, text)
    actual_hash = hashlib.sha256(normalized.encode()).hexdigest()

    if declared_hash != actual_hash:
        print("ERROR: prereg file has been modified since lock.")
        print(f"  declared: {declared_hash}")
        print(f"  actual:   {actual_hash}")
        sys.exit(1)

    print(f"[OK] prereg integrity: {declared_hash[:12]}...")

if __name__ == "__main__":
    main()
```

CI 跑这个；pre-commit 也跑这个；任何编辑器误改都会被立即拦住。

---

## Phase 6 — Tested-Model Runner Architecture

### 6.1 Base runner

`src/physlit/runners/base.py`:

```python
from abc import ABC, abstractmethod
from dataclasses import dataclass, asdict
from pathlib import Path
import json, time, uuid

@dataclass
class TrialRecord:
    """One trial of one stage. Saved verbatim."""
    framework_id: str
    model_full_version: str   # "claude-opus-4-7-20260101", not "claude-opus"
    stage: str                # "induction" | "formulation" | "prediction"
    trial_index: int          # 0..4
    temperature: float
    prompt_version: str
    prompt_text: str          # full prompt sent
    response_text: str        # full response received
    response_timestamp_utc: str
    api_session_id: str       # UUID per trial — proves fresh session
    cost_usd_estimate: float

class TestedModelRunner(ABC):
    """Base class. Every concrete runner enforces fresh sessions per trial."""

    @property
    @abstractmethod
    def model_family(self) -> str: ...   # "anthropic" | "openai" | "google"

    @abstractmethod
    def get_model_version(self) -> str:
        """Query the API for the exact model version string. Fail-fast on mismatch."""

    @abstractmethod
    def call_model(self, prompt: str, temperature: float, session_id: str) -> str:
        """Single API call. MUST create a fresh client / session each call.
        Multi-turn or context reuse is FORBIDDEN at this layer."""

    def run_trial(
        self, framework_id: str, stage: str, prompt_text: str,
        prompt_version: str, trial_index: int, temperature: float
    ) -> TrialRecord:
        session_id = str(uuid.uuid4())   # fresh session UUID
        start = time.time()
        response_text = self.call_model(prompt_text, temperature, session_id)
        cost = self._estimate_cost(prompt_text, response_text)
        return TrialRecord(
            framework_id=framework_id,
            model_full_version=self.get_model_version(),
            stage=stage,
            trial_index=trial_index,
            temperature=temperature,
            prompt_version=prompt_version,
            prompt_text=prompt_text,
            response_text=response_text,
            response_timestamp_utc=time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            api_session_id=session_id,
            cost_usd_estimate=cost,
        )

    def save_trial(self, record: TrialRecord, results_root: Path) -> None:
        out_dir = results_root / record.model_full_version / record.framework_id / record.stage
        out_dir.mkdir(parents=True, exist_ok=True)
        out_file = out_dir / f"trial_{record.trial_index}_t{record.temperature}.json"
        out_file.write_text(json.dumps(asdict(record), indent=2, sort_keys=True))

    @abstractmethod
    def _estimate_cost(self, prompt: str, response: str) -> float: ...
```

### 6.2 Prompt loader

`prompts/stage1_induction.md`:

```markdown
---
version: v1
stage: induction
description: Stage 1 — given observations, produce candidate laws.
---

You are presented with a list of observed phenomena from a world whose
physics may not match real physics.

**Critical instruction**: do not use modern physics concepts (force, mass,
acceleration, momentum, energy, inertia, conservation laws) unless they
are clearly derivable from the observations alone.

Observations:
{{observations}}

Your task: propose a self-consistent set of laws that explains every
observation above. Use only concepts that the observations themselves
introduce or imply.

Return your laws as a numbered list. Be specific.
```

`src/physlit/prompts/loader.py`:

```python
import re
from pathlib import Path

class PromptTemplate:
    def __init__(self, path: Path):
        text = path.read_text()
        # parse front-matter
        m = re.match(r"---\n(.+?)\n---\n(.*)", text, re.DOTALL)
        if not m:
            raise ValueError(f"No front-matter in {path}")
        import yaml
        self.meta = yaml.safe_load(m.group(1))
        self.body = m.group(2)
        self.version = self.meta["version"]
        self.stage = self.meta["stage"]

    def render(self, **kwargs) -> str:
        result = self.body
        for key, val in kwargs.items():
            result = result.replace("{{" + key + "}}", str(val))
        return result
```

---

## Phase 7 — Per-Stage Runners (Claude / OpenAI / Gemini)

### 7.1 Claude runner

`src/physlit/runners/claude.py`:

```python
import os, anthropic
from .base import TestedModelRunner

class ClaudeRunner(TestedModelRunner):
    model_id = "claude-opus-4-7-20260101"   # PIN exact version

    @property
    def model_family(self) -> str:
        return "anthropic"

    def get_model_version(self) -> str:
        # Anthropic API exposes the version via response.model
        # Fail-fast if returned version != configured
        return self.model_id

    def call_model(self, prompt: str, temperature: float, session_id: str) -> str:
        client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
        # FRESH client per call — do NOT cache
        msg = client.messages.create(
            model=self.model_id,
            max_tokens=2048,
            temperature=temperature,
            messages=[{"role": "user", "content": prompt}],
            metadata={"user_id": session_id},   # log session for audit
        )
        # verify version
        if msg.model != self.model_id:
            raise RuntimeError(f"Version mismatch: expected {self.model_id}, got {msg.model}")
        return msg.content[0].text

    def _estimate_cost(self, prompt: str, response: str) -> float:
        # Anthropic pricing: input $15/Mtok, output $75/Mtok (Opus 4.7 example)
        in_tokens = len(prompt) / 3.5    # rough char-to-token
        out_tokens = len(response) / 3.5
        return (in_tokens * 15 + out_tokens * 75) / 1_000_000
```

### 7.2 OpenAI / Gemini runners

照 Claude runner 的结构改动 SDK 调用即可。三个 runner 的接口一致，所以 `orchestrator.py` 不需要 if-else 分支。

### 7.3 Orchestrator

`src/physlit/runners/orchestrator.py`:

```python
"""Run all 3 stages × N trials × 2 temperatures for one (model, framework)."""
from pathlib import Path
from .claude import ClaudeRunner
from .openai_runner import OpenAIRunner
from .gemini import GeminiRunner

N_TRIALS = 5
TEMPERATURES = [0.0, 0.7]   # headline + secondary

def run_full_evaluation(runner, framework_id: str, results_root: Path = Path("results")):
    framework_dir = Path("frameworks") / framework_id
    observations = (framework_dir / "observations.md").read_text()

    # Stage 1: Induction
    prompt1 = PromptTemplate(Path("prompts/stage1_induction.md")).render(
        observations=observations
    )
    induction_responses = []
    for temp in TEMPERATURES:
        for trial_idx in range(N_TRIALS):
            record = runner.run_trial(
                framework_id, "induction", prompt1, "v1", trial_idx, temp
            )
            runner.save_trial(record, results_root)
            induction_responses.append(record)

    # Stage 2: Formulation — feed the induced laws back
    # ... (similar pattern, prompt2 includes the model's own induction output)

    # Stage 3: Prediction — load prediction_scenarios.yaml
    # ... (loop scenarios × trials × temperatures)

    # Meta-cognitive question (single run, not 5 trials)
    # ... (records to results/<model>/<framework>/meta/single.json)
```

### 7.4 Cost gating

跑大批量之前先估价：

```python
def estimate_run_cost(runner, framework_id: str) -> float:
    # rough estimate based on prompt sizes × N_TRIALS × 2 temps × 4 stages
    return runner._estimate_cost(...) * N_TRIALS * 2 * 4

if estimated > 10.0:
    print(f"Estimated cost: ${estimated:.2f}. Continue? [y/N]")
    if input().strip().lower() != "y":
        return
```

CI 不跑实际 model 调用（太贵），只跑模拟 / 单元测试。Phase 12 解释。

---

## Phase 8 — Dual-Judge Inter-Rater Pipeline

### 8.1 Judge base

`src/physlit/judges/base.py`:

```python
@dataclass
class JudgmentRecord:
    framework_id: str
    model_under_test: str
    stage: str
    trial_index: int
    judge_model: str
    verdict: bool                 # pass/fail binary
    reasoning: str                # judge's stated reasoning
    judge_session_id: str

class Judge(ABC):
    @abstractmethod
    def judge(self, criteria: str, model_response: str, framework_context: str) -> JudgmentRecord: ...
```

### 8.2 双 judge 跑 + 一致性

```python
def evaluate_with_dual_judge(trial_record: TrialRecord, criteria: str, framework_context: str):
    judge_claude = ClaudeJudge()
    judge_gpt = GPTJudge()

    j1 = judge_claude.judge(criteria, trial_record.response_text, framework_context)
    j2 = judge_gpt.judge(criteria, trial_record.response_text, framework_context)

    return {
        "claude_verdict": j1.verdict,
        "gpt_verdict": j2.verdict,
        "agreement": j1.verdict == j2.verdict,
        "claude_reasoning": j1.reasoning,
        "gpt_reasoning": j2.reasoning,
    }
```

### 8.3 Disagreement 公开报告

每个 framework 的 disagreement rate（一致同意 vs 分歧）公开在 `analysis/inter_rater.md`。低同意率 = methodology quality 弱信号。

```python
def disagreement_rate(judgments: list[dict]) -> float:
    return sum(1 for j in judgments if not j["agreement"]) / len(judgments)
```

> 任何 disagreement rate > 25% 的 framework 在公开发布前必须人工 audit。

---

## Phase 9 — Cross-Stage / Cross-Set / Meta Analysis

### 9.1 Cross-stage consistency

`src/physlit/analysis/cross_stage.py`:

```python
def check_cross_stage_consistency(
    induction_record: TrialRecord,
    formulation_record: TrialRecord,
    prediction_records: list[TrialRecord],
    framework_id: str,
) -> dict:
    """Use a judge to check: do the model's stage-3 predictions cohere
    with the laws it induced in stage 1 and formalized in stage 2?

    Failure example: induced 'v ∝ F' but predicted inertia in stage 3.
    """
    judge = ClaudeJudge()
    prompt = f"""
    Stage 1 (induced laws):
    {induction_record.response_text}

    Stage 2 (formalized laws):
    {formulation_record.response_text}

    Stage 3 (predictions on novel scenarios):
    {chr(10).join(p.response_text for p in prediction_records)}

    Question: do the stage-3 predictions follow consistently from the
    stage-1/stage-2 laws? Answer binary: COHERENT / INCOHERENT.
    Provide one example of incoherence if INCOHERENT.
    """
    return judge.judge_freeform(prompt)
```

### 9.2 Cross-set consistency (meta-cognitive)

After all frameworks evaluated, ask the same model meta-questions about its own behavior:

```python
def cross_set_meta_question(model_runner, framework_results: dict) -> str:
    summary = "\n".join(f"- {fid}: stages passed={r['stages_passed']}" for fid, r in framework_results.items())
    prompt = f"""
    You evaluated {len(framework_results)} physics frameworks. Here is your
    summary stage-pass record:

    {summary}

    Question: in which frameworks did you maintain consistency throughout,
    and in which did you slip back to standard physics? Be honest and specific.
    """
    return model_runner.call_model(prompt, temperature=0.0, session_id=str(uuid.uuid4()))
```

Compare model's self-report vs actual cross-stage results → meta-cognitive accuracy score.

### 9.3 Pre-registered prediction comparison

`src/physlit/analysis/prereg_comparison.py`:

```python
def evaluate_prereg(prereg_path: Path, results_summary: dict) -> dict:
    """For each P1-P5 prediction, evaluate confirmed/partial/refuted."""
    return {
        "P1_induction_failure_under_conflict": "confirmed",  # e.g.
        "P2_stage_dissociation": "partially_confirmed",
        "P3_meta_miscalibration": "refuted",
        # ...
    }
```

### 9.4 Capability matrix data

`analysis/capability_matrix.json`:

```json
{
  "models": ["claude-opus-4-7-20260101", "gpt-5-20260201", "gemini-3-20260301"],
  "frameworks": ["01_aristotelian", "06_f_equals_mv", "..."],
  "matrix": {
    "claude-opus-4-7-20260101": {
      "01_aristotelian": {
        "induction": "FAIL",
        "formulation": "PASS",
        "prediction": "FAIL",
        "cross_stage": "FAIL",
        "meta_cognitive": "FAIL"
      }
    }
  },
  "prereg_comparison": {...},
  "generated_at": "2026-XX-XXT00:00:00Z"
}
```

---

## Phase 10 — GitHub Pages Static Site

### 10.1 Jinja2 templates

`src/physlit/site/templates/index.html.j2`:

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>PhysLit — Physics Literacy Probe</title>
  <link rel="stylesheet" href="static/style.css">
</head>
<body>
  <h1>PhysLit Capability Matrix</h1>
  <p>Generated {{ generated_at }}.</p>

  <table class="capability-matrix">
    <thead>
      <tr>
        <th>Framework</th>
        {% for model in models %}<th>{{ model }}</th>{% endfor %}
      </tr>
    </thead>
    <tbody>
      {% for fw in frameworks %}
      <tr>
        <td>{{ fw }}</td>
        {% for model in models %}
        <td class="{{ matrix[model][fw].cross_stage|lower }}">
          {{ matrix[model][fw].cross_stage }}
        </td>
        {% endfor %}
      </tr>
      {% endfor %}
    </tbody>
  </table>

  <section>
    <h2>Pre-Registered Predictions</h2>
    {% for pid, verdict in prereg_comparison.items() %}
    <p>{{ pid }}: <strong>{{ verdict }}</strong></p>
    {% endfor %}
  </section>
</body>
</html>
```

### 10.2 Render script

`src/physlit/site/render.py`:

```python
import json
from pathlib import Path
from jinja2 import Environment, FileSystemLoader

def render_site():
    data = json.loads(Path("analysis/capability_matrix.json").read_text())
    env = Environment(loader=FileSystemLoader("src/physlit/site/templates"))
    tmpl = env.get_template("index.html.j2")
    output = tmpl.render(**data)
    out_dir = Path("site/build")
    out_dir.mkdir(exist_ok=True, parents=True)
    (out_dir / "index.html").write_text(output)
    # copy static/
    import shutil
    shutil.copytree("src/physlit/site/static", out_dir / "static", dirs_exist_ok=True)
```

### 10.3 没用 mkdocs/Hugo 的理由

研究项目的输出是简单的：一个 capability matrix + 几个分析报告。Plain HTML/Jinja2 = 无依赖、无 theme 调试、可托管在 GitHub Pages 任何配置下。

---

## Phase 11 — Reproducibility Kit

### 11.1 `replicate.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${ANTHROPIC_API_KEY:-}" || -z "${OPENAI_API_KEY:-}" || -z "${GOOGLE_API_KEY:-}" ]]; then
  echo "Usage: ANTHROPIC_API_KEY=... OPENAI_API_KEY=... GOOGLE_API_KEY=... ./replicate.sh"
  exit 1
fi

# Step 1: validate environment
uv sync
uv run python scripts/validate_specs.py
uv run python scripts/verify_prereg_integrity.py

# Step 2: generate Tier 1 observations (deterministic)
uv run python scripts/generate_observations.py
uv run python scripts/generate_ground_truth.py

# Step 3: estimate cost
COST=$(uv run python scripts/estimate_cost.py)
echo "Estimated total cost: \$${COST}"
read -p "Continue? [y/N] " yn
[[ "$yn" == "y" ]] || exit 0

# Step 4: run all (model × framework) evaluations
uv run python scripts/run_all_evaluations.py

# Step 5: dual-judge inter-rater
uv run python scripts/run_judges.py

# Step 6: cross-stage / cross-set / meta analysis
uv run python scripts/analyze_results.py

# Step 7: generate capability matrix + render site
uv run python scripts/build_site.py

echo "Done. site/build/index.html ready."
echo "Compare your results against analysis/capability_matrix.json checked into the repo."
```

### 11.2 Cost estimator

`scripts/estimate_cost.py`：枚举 (model, framework, stage, trials, temps) 计算 token 预算总和 × API 价格。把估算输出到 stdout 让 `replicate.sh` 拦截。

---

## Phase 12 — CI/CD

### 12.1 `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - run: uv sync
      - run: uv run ruff check .
      - run: uv run mypy src/
      - run: uv run pytest tests/
      - run: uv run python scripts/validate_specs.py
      - run: uv run python scripts/verify_prereg_integrity.py
      # NOTE: we do NOT run replicate.sh in CI — too expensive.
      # Instead we run a smoke test that mocks the API.
      - run: uv run pytest tests/test_runners_with_mock.py
```

### 12.2 `.github/workflows/deploy-site.yml`

```yaml
name: Deploy site

on:
  push:
    branches: [main]
    paths: ["analysis/**", "src/physlit/site/**"]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      pages: write
      id-token: write
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v3
      - run: uv sync
      - run: uv run python -c "from physlit.site.render import render_site; render_site()"
      - uses: actions/upload-pages-artifact@v3
        with:
          path: site/build
      - uses: actions/deploy-pages@v4
```

### 12.3 Sprint tracking（拷自 playbook stack/）

`sprint-report.yml` + `notify-playbook.yml` 直接复制，把 `project_id` 改成 `physlit`。Repo 的 commit 活跃度自动同步回 `indie-product-playbook/ideas/physlit.md` 的 Sprint Summary section。

---

## 常见坑

| 坑 | 原因 | 解法 |
|----|------|------|
| Prereg 文件被编辑器自动 save 改坏 | 编辑器加 trailing whitespace 等 | pre-commit hook 在每次 stage 时验证 hash |
| Tier 1 simulator 输出不确定 | 不小心引入了 random / 时间依赖 | 测试强制 byte-identity；`tests/test_simulators.py::test_determinism` |
| Model 版本悄悄变 | API alias 解析到新版本 | runner 调用时校验 `response.model == config.model_id`，不一致直接 raise |
| Multi-turn 偷懒 | 容易在 Stage 1 → Stage 2 复用 conversation | base runner 强制 fresh client + UUID session per call |
| Judge prompt 偏 | LLM judge 对某种回答有偏好 | 双 judge + disagreement 公开报告 + 高 disagreement 时人工 audit |
| Cost 失控 | 大批量跑一次 $1k+ | `replicate.sh` 强制 cost estimate 确认；CI 不跑实 API |
| 静态站 build 路径错 | GitHub Pages 默认从 root | `actions/upload-pages-artifact` 显式指定 `site/build/` |
| 复现脚本在新机器跑不了 | uv 没装、Python 版本不对 | `replicate.sh` 第一步显式 `uv sync`；`.python-version` 锁定 |

---

## 环境变量完整清单

```bash
# Tested model APIs
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
GOOGLE_API_KEY=

# Judge APIs (可以和 tested 复用，但建议分开 key 便于配额追踪)
ANTHROPIC_JUDGE_KEY=
OPENAI_JUDGE_KEY=

# 不需要：
# DATABASE_URL — 没数据库
# Stripe keys — 不收费
# Supabase keys — 没 auth
# Vercel — 用 GitHub Pages
```

---

## 新项目 Checklist

```
□ git init + uv init --python 3.11
□ uv add anthropic openai google-genai pydantic pyyaml jinja2 click
□ uv add --dev pytest ruff mypy pre-commit
□ 创建目录结构（见 Phase 0.2）
□ 写 .gitignore + LICENSE (MIT) + LICENSE-DATA (CC BY 4.0)
□ 写 README.md 骨架
□ 设置 pre-commit (.pre-commit-config.yaml + uv run pre-commit install)
□ Phase 1: 写 FrameworkSpec pydantic schema + 第一个 spec.yaml (Aristotelian)
□ Phase 1: 写 scripts/validate_specs.py
□ Phase 2: 写 Tier1Simulator base + 第一个 simulator (F=mv)
□ Phase 2: tests/test_simulators.py 强制确定性
□ Phase 3: Tier 2 stub class（v0.1 raise NotImplementedError）
□ Phase 4: prediction_scenarios.yaml + scripts/generate_ground_truth.py
□ Phase 4: 手写 Aristotelian 的 ground_truth_predictions.md（标 manual）
□ Phase 5: 写 predictions/v0_1_prereg.md（含 P1-P5 全文）
□ Phase 5: scripts/lock_prereg.sh + scripts/verify_prereg_integrity.py
□ Phase 5: 跑 lock_prereg.sh，git tag prereg-v0.1-locked
□ Phase 6: prompts/*.md 四个 stage prompt 模板（versioned）
□ Phase 6: src/physlit/runners/base.py + prompts/loader.py
□ Phase 7: ClaudeRunner + OpenAIRunner + GeminiRunner（各 pin 版本号）
□ Phase 7: orchestrator.py 跑 N=5 × 2 temp × 3 stages
□ Phase 7: cost gating
□ Phase 8: ClaudeJudge + GPTJudge + dual-judge runner
□ Phase 8: disagreement rate 报告
□ Phase 9: cross_stage / cross_set / meta analysis
□ Phase 9: prereg comparison
□ Phase 9: capability_matrix.json
□ Phase 10: Jinja2 template + render script
□ Phase 10: 本地 build 验证
□ Phase 11: replicate.sh 端到端跑一遍验证
□ Phase 12: ci.yml + deploy-site.yml + sprint-report.yml + notify-playbook.yml
□ Phase 12: GitHub repo Settings → Pages → 启用 GitHub Actions source
□ Phase 12: GitHub Secrets 加 PLAYBOOK_TOKEN
□ 公开 release v0.1
```

---

## 成功判定

参照 `ideas/physlit.md §9`：

**v0.1 (Phase 0-9 完成 + Phase 10-12 公开 release 前必须完成)**：
- repo 公开
- 1 个 phenomenon set (Aristotelian) 完整跑通
- 3 个 frontier 模型评估完成
- prereg locked + integrity check 在 CI 跑过
- replicate.sh 在外部环境跑通
- capability matrix 静态站可访问

**v0.5**：5-7 个 sets + arXiv preprint posted + 至少 1 次外部复现尝试

**v1.0**：15-20 sets + 5+ 学术引用 + 至少 1 个 major lab 引用方法论

---

## Sprint Summary

_This section will be auto-updated by the sync-from-projects workflow once the repo is created._
