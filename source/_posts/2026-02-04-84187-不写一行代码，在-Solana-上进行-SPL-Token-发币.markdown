---
layout: post
title: 不写一行代码，在 Solana 上进行 SPL Token 发币
comments: true
post_id: 84187
permalink: /archives/84187.html
date: 2026-02-04 10:22:16
categories:
tags: ["web3", "solana"]
---

按照之前的文章，本地安装 Solana CLI 之后，会有一个 spl-token 的命令。
在发币之后需要先了解一下 Solana SPL 相关的概念。


类似于 Ethereum 的 ERC20 程序， Solana 官方提供了一个 SPL Token 程序，专门是用于发币的，对应的 Program ID 是 `TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA`。

### 创建 Mint Account
先创建一个 Mint Account，用于后续的铸币。这里我们为自己的 token 设置精度为6位小数。

```bash
$ spl-token create-token --decimals=6
Creating token CuDVhtzgm9A9Pjdfvv98bph2noKAWf22Z1FBbLK1DnAk under program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA

Address:  CuDVhtzgm9A9Pjdfvv98bph2noKAWf22Z1FBbLK1DnAk
Decimals:  6

Signature: 3f8q7Dserwzf4NHeCbmgCepGfBYLtuimi8tznTBunbKTwdFqHRMqr6iR1kTc8hfKF5DPtAeveQ4EjBzmQWbXLCjb
```

### 创建 Associated Token Account 
再创建一个ATA(Associated Token Account)，用于接收铸造的币。

```bash
# 这里为刚刚的 Mint Account 创建 ATA
$ spl-token create-account CuDVhtzgm9A9Pjdfvv98bph2noKAWf22Z1FBbLK1DnAk
Creating account EvvQiKLYW67mGSb6oDzGEimJMjGYb1No3ppQWZgB84v

Signature: 3mRP9mMtTZZSFJnWXAvCffHVgQF3jdgecAqnmUTSTVoi51HyfWoe3fvWWeC3v71XML9h3mwjwrnpG8zquXrgy1b2
```

## 铸币
往刚刚创建的 ATA 账号发10个币；因为我们的 token 有6位小数，所以实际发的币需要乘以 10*6。

```bash
$ spl-token mint CuDVhtzgm9A9Pjdfvv98bph2noKAWf22Z1FBbLK1DnAk 10000000 EvvQiKLYW67mGSb6oDzGEimJMjGYb1No3ppQWZgB84v
Minting 10000000 tokens
  Token: CuDVhtzgm9A9Pjdfvv98bph2noKAWf22Z1FBbLK1DnAk
  Recipient: EvvQiKLYW67mGSb6oDzGEimJMjGYb1No3ppQWZgB84v

Signature: 87psf5aZak7BCQriScEkioqTW2ozvJn5K6mmjTibstVTWofwiKom3FvWGkkiddJ6oq8KUa2vLkYSKku1r87wdst
```

至此 Solana 的基本发币操作就完成了。


