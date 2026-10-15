# ERC-20 Learning Project

一个从零搭建的 Foundry 教学项目，用于理解 ERC-20 的核心业务逻辑、测试方法与 GitHub 协作流程。

> [!WARNING]
> 本项目用于学习，未经安全审计，请勿直接用于生产环境或管理真实资产。

## 已实现功能

- ERC-20 元数据：`name`、`symbol`、`decimals`
- 初始供应量和账户余额
- 直接转账：`transfer`
- 授权额度：`approve`、`allowance`
- 授权转账：`transferFrom`
- `Transfer` 和 `Approval` 事件
- ERC-6093 风格的结构化错误
- `IERC20` 核心接口
- 正常路径、失败路径和边界条件单元测试

## 项目结构

```text
src/
├── LearningToken.sol
└── interfaces/
    └── IERC20.sol
test/
└── LearningToken.t.sol
```

## 环境要求

- Git
- Foundry
- Solidity 0.8.26（由 `foundry.toml` 固定）

## 获取项目

项目使用 `forge-std` Git submodule：

```bash
git clone --recurse-submodules \
  https://github.com/abnsatime/foundry-learning-demo.git

cd foundry-learning-demo
```

如果已经完成普通 clone：

```bash
git submodule update --init --recursive
```

## 构建与测试

```bash
forge fmt --check
forge build
forge test -vvv
forge coverage --report summary
```

当前功能分支包含 23 个单元测试，覆盖元数据、初始供应量、转账、授权、事件、自定义错误和关键边界条件。

## 学习路线

1. 手写 ERC-20 核心逻辑并理解 ABI。
2. 使用 Foundry 编写单元测试。
3. 通过接口约束外部 API。
4. 使用功能分支和 Pull Request 协作。
5. 后续加入 fuzz、invariant、部署脚本和 CI/CD。
