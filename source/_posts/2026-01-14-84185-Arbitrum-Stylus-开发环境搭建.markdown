---
layout: post
title: Arbitrum Stylus 开发环境搭建
comments: true
post_id: 84185
permalink: /archives/84185.html
date: 2026-01-14 09:44:17
categories:
tags: ["web3", "evm"]
---

### rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
```
我是用的 [mise](https://github.com/jdx/mise) 工具来安装的
```bash
mise install rust@1.92.0
```


### Stylus CLI
Arbitrum 的开发框架
```bash
cargo install cargo-stylus
```

因为 Arbitrum 的合约程序最终会被编译为 webassembly，所以还需要安装 wasm 相关的编译工具

```bash
rustup target add wasm32-unknown-unknown
```

### foundry
foundry 是一个 EVM 智能合约开发测试的工具。  
下载 foundry 相关的命令行工具： https://github.com/foundry-rs/foundry/releases

### solc
下载 solc 的二进制文件： https://github.com/argotorg/solidity/releases

### 本地开发结点
需要先安装 docker 环境
```bash
git clone https://github.com/OffchainLabs/nitro-devnode.git
cd nitro-devnode
./run-dev-node.sh
```

本地结点的账号、密钥：
```
Address: 0x3f1Eae7D46d88F08fc2F8ed27FCb2AB183EB2d0E
Private key: 0xb6b15c8cb491557369f3c7d2c287b053eb229daa9c22138887752191c9520659
```

如果想要外部也能够连接本地的结点，那么需要修改一个 `run-dev-node.sh` 这个脚本，在 `docker run` 这条命令后面再加上 ` --http.vhosts=*` 参数。

## 开发流程
### 创建项目
```bash
cargo stylus new <name>
```

### 编译
```bash
cargo stylus build
```

编译成功会生成 target/wasm32-unknown-unknown/release/xxx.wasm 文件

### 部署
验证是否能够部署
```bash
cargo stylus check -e http://127.0.0.1:8547
```

仅计算部署所需的 gas 费
```bash
cargo stylus deploy \
  --endpoint=http://127.0.0.1:8547 \
  --private-key=<YOUR_PRIVATE_KEY> \
  --estimate-gas-only
```
  
部署合约
```bash
cargo stylus deploy \
  --endpoint=http://127.0.0.1:8547 \
  --private-key=<YOUR_PRIVATE_KEY>
```
  
导出合约 contract ABI，需要先安装 solc
```bash
cargo stylus export-abi --output=./abi.json --json
```

### 合约测试
调用合约程序查询数据：

```bash
cast call --rpc-url http://127.0.0.1:8547  <合约地址> "合约函数签名" [<函数参数>]
```

例如，对于一个 ERC20 的程序，查询账户余额：  
```bash
cast call --rpc-url $ARB_RPC_URL $CONTRACT_TOKEN "balanceOf(address)(uint256)" $PUBLIC_KEY
```

调用合约创建交易：

```bash
cast send --rpc-url http://127.0.0.1:8547 --private-key <自己的私钥> <合约地址> "合约函数签名" [<函数参数>]
```

例如，一个 ERC20 的转账操作：  
```bash
cast send --rpc-url $ARB_RPC_URL --private-key $PRIVATE_KEY $CONTRACT_TOKEN "transfer(address, uint256)" $TARGET_ADDRESS $AMOUNT
```
