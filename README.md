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
script/
└── DeployLearningToken.s.sol
test/
├── LearningToken.t.sol
└── invariant/
    ├── LearningToken.invariant.t.sol
    └── LearningTokenHandler.sol
deployments/
└── sepolia.json
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

测试套件包含 23 个示例单元测试、3 个 fuzz 性质和 2 个 stateful invariants，覆盖元数据、初始供应量、转账、授权、事件、自定义错误、关键边界条件与余额守恒。

单独运行 invariant 测试：

```bash
forge test --match-contract LearningTokenInvariantTest -vv
```

## Anvil 本地部署

终端 A 启动本地链：

```bash
anvil
```

终端 B 使用 Anvil 输出的测试私钥部署：

```bash
forge script \
  script/DeployLearningToken.s.sol:DeployLearningToken \
  --rpc-url http://127.0.0.1:8545 \
  --private-key <ANVIL_TEST_PRIVATE_KEY> \
  --broadcast
```

不加 `--broadcast` 时只模拟交易；加上后才会向 RPC 发送交易。部署完成后可以验证：

```bash
cast receipt <TRANSACTION_HASH> \
  --rpc-url http://127.0.0.1:8545

cast call <TOKEN_ADDRESS> \
  "totalSupply()(uint256)" \
  --rpc-url http://127.0.0.1:8545
```

Anvil 私钥是公开测试凭据，只能用于本地开发，绝不能用于测试网或主网资产。

## Sepolia 部署

LearningToken 已部署并通过 Etherscan Exact Match 源码验证：

| 字段 | 值 |
|---|---|
| Network | Sepolia |
| Chain ID | `11155111` |
| Contract | [`0x3fBbEF670f4d6F58A257FE811d7Cad60D6135FD4`](https://sepolia.etherscan.io/address/0x3fBbEF670f4d6F58A257FE811d7Cad60D6135FD4#code) |
| Deployment transaction | [`0xa6132227d53363dcb5ddd399e45061163ad4e2c73654628be8d2bd1a3f1fcd1e`](https://sepolia.etherscan.io/tx/0xa6132227d53363dcb5ddd399e45061163ad4e2c73654628be8d2bd1a3f1fcd1e) |
| Deployer | `0x766956dBFb9914dEDfFBc6c8bD25002aA4B6864A` |
| Initial supply | `1,000,000 LRN` |
| Compiler | Solidity `0.8.26` |
| Source verification | Exact Match |

完整的机器可读部署信息见 [`deployments/sepolia.json`](deployments/sepolia.json)。

只读查询示例：

```bash
cast call \
  0x3fBbEF670f4d6F58A257FE811d7Cad60D6135FD4 \
  "totalSupply()(uint256)" \
  --rpc-url https://ethereum-sepolia-rpc.publicnode.com
```

## 学习路线

1. 手写 ERC-20 核心逻辑并理解 ABI。
2. 使用 Foundry 编写单元测试。
3. 通过接口约束外部 API。
4. 使用功能分支和 Pull Request 协作。
5. 使用 fuzz 和 invariant 测试验证状态性质。
6. 使用部署脚本、Anvil 和 Cast 完成本地部署。
7. 部署到 Sepolia 并完成 Etherscan 源码验证。
8. 后续加入 CI/CD。
