---
layout: 'post'
title: '使用TypeScript开发Express应用'
date: '2019-11-04T03:01:06.658Z'
comments: true
post_id: '84176'
permalink: '/archives/84176.html'
categories: ["Web开发"]
tags: ["typescript", "node", "js"]
---

## 首先创建新项目

```
yarn init
```

## 然后安装 express

```
yarn add express
yarn add @types/express @types/node --dev
```

## 安装 TypeScript

```
yarn add --dev typescript
```

## 配置 webpack

这是最麻烦的一步。先安装 webpack:

```
yarn add --dev webpack webpack-cli webpack-node-externals ts-loader
yarn add --dev nodemon webpack-shell-plugin
```

添加 `webpack.config.js`:
```
const path = require('path');
const nodeExternals = require('webpack-node-externals');
const WebpackShellPlugin = require('webpack-shell-plugin');

const { NODE_ENV = 'production' } = process.env;
const rootPath = path.resolve(__dirname)

let plugins = []
if (NODE_ENV === 'development') {
  plugins.push(new WebpackShellPlugin({
    onBuildEnd: ['yarn run:dev']
  }))
}

module.exports = {
  entry: path.resolve(rootPath, './src/index.ts'),
  mode: NODE_ENV,
  target: 'node',
  watch: NODE_ENV === 'development',
  externals: [ nodeExternals() ],
  output: {
    path: path.resolve(rootPath, 'build', NODE_ENV === 'development' ? 'dev' : 'prod'),
    filename: 'index.js'
  },
  resolve: {
    extensions: ['.ts', '.js'],
  },
  plugins: plugins,
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: [
          'ts-loader',
        ]
      }
    ]
  },
}
```

添加 `tsconfig.json`:
```
{
  "compilerOptions": {
    "module": "commonjs",
    "target": "es5",
    "noImplicitAny": false,
    "sourceMap": true,
    "outDir": "build"
  },
  "exclude": [
    "node_modules",
    "build",
    "config",
    "release"
  ]
}
```

在 `package.json` 中添加相关命令:
```
"scripts": {
  "start": "node build/prod/index.js",
  "start:dev": "NODE_ENV=development node node_modules/webpack/bin/webpack.js --config webpack.config.js",
  "build": "NODE_ENV=production node node_modules/webpack/bin/webpack.js --config webpack.config.js",
  "run:dev": "NODE_ENV=development nodemon build/dev/index.js",
}
```

这样在开发过程只需要执行 `yarn run start:dev` 启动开发服务器即可，在代码有改动之后会自己重新 build 并重启服务。
开发完成之后执行 `yarn build` 进行打包发布。

## 使用 jest 进行测试(可选)

安装 jest：
```
yarn add -D jest @types/jest ts-jest supertest
```


添加 `jest.config.js`:
```
module.exports = {
  testEnvironment: 'node',
  transform: {
    "^.+\\.ts$": "ts-jest"
  },
};
```

相应的测试文件的文件名以 `.test.ts` 结尾。

然后在 `package.json` 中添加相关命令：
```
"scripts": {
  "test": "jest"
}
```

最终项目目录结构如下：
```
.
├── jest.config.js
├── package.json
├── src
│   └── index.ts
├── tests
│   └── index.test.ts
├── tsconfig.json
├── webpack.config.js
└── yarn.lock
```


参考源代码： https://github.com/wusuopu/baidu-pan-cli
