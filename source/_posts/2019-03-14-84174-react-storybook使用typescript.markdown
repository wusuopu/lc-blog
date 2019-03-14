---
layout: 'post'
title: 'react storybook使用typescript'
date: '2019-03-14T02:27:36.262Z'
comments: true
post_id: '84174'
permalink: '/archives/84174.html'
categories: ["前端相关"]
tags: ["js", "react"]
---

在前面的文章有介绍<a href="84172.html" target="_blank">在storybook中使用antd</a>。
之前开发js是使用的flow来作类型检查，最近想尝试一下typescript。
如果是从头创建一个空的typescript项目则相对就比较简单，但是现在我们是需要将之前的create-react-app项目迁移到typescript。

## 在create-react-app中添加typescript
参考 https://facebook.github.io/create-react-app/docs/adding-typescript
react-scripts从2.1.0版本开始就支持typescript了，这里我们先将项目的react-scripts依赖升级到最新版本：
```
yarn add --exact react-scripts@2.1.8
```

然后再添加typescript依赖：
```
yarn add typescript @types/node @types/react @types/react-dom @types/jest
```

然后将 `src/index.js` 更名为 `src/index.tsx`
接着创建 `tsconfig.json` 文件：
```
{
  "compilerOptions": {
    "module": "esnext",
    "target": "es5",
    "lib": ["es5", "es6", "es7", "es2017", "dom"],
    "sourceMap": true,
    "allowJs": true,
    "moduleResolution": "node",
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": false,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "preserve"
  },
  "include": [
    "src/**/*"
  ]
}
```


## 在storybook中添加typescript
参考 https://storybook.js.org/docs/configurations/typescript-config/
同样也先将storybook升级到最新版：
```
yarn add --dev --exact @storybook/addons@5.0.1 @storybook/react@5.0.1
```
然后再添加依赖：
```
yarn add --dev awesome-typescript-loader @types/storybook__react @storybook/addon-info react-docgen-typescript-webpack-plugin ts-jest
```

接着修改webpack配置，对应`.storybook/webpack.config.js`文件：
```
const path = require("path");
const antdTheme = {
  '@primary-color': '#846bc1',
}

module.exports = ({ config, mode }) => {
  config.module.rules.push({
    test: /\.less$/,
    use: [{
      loader: "style-loader"
    }, {
      loader: "css-loader"
    }, {
      loader: "less-loader",
      options: {
        modifyVars: antdTheme,    // 如果要自定义主题样式
        javascriptEnabled: true
      }
    }]
  });
  config.module.rules.push({
    test: /\.(ts|tsx)$/,
    loader: require.resolve('awesome-typescript-loader'),
    options: { configFileName: path.resolve(__dirname, './tsconfig.json') }
  });
  config.resolve.extensions.push('.ts', '.tsx');

  return config;
};
```

以及babel配置，对应`.storybook/babelrc.js`文件：
```
module.exports = function(api) {
  api.cache.forever();
  return {
    "presets": [
      [
        "@babel/preset-env",
        {
          "modules": false,
          "targets": {
            "browsers": [
              ">1%",
              "last 4 versions",
              "Firefox ESR",
              "not ie < 11"
            ]
          }
        }
      ],
      "@babel/preset-react"
    ],
    "plugins": [
      [
        "import",
        {
          "libraryName": "antd",
          "style": true
        }
      ]
    ]
  }
}
```

同时修改storybook配置`.storybook/config.js`，让其支持.tsx文件：
将之前的：
```
const req = require.context('../src/components', true, /\.stories\.js$/)
```
修改为：
```
const req = require.context('../src/components', true, /\.stories\.[jt]sx?$/)
```

最后再创建 `.storybook/tsconfig.json` 文件：
```
{
  "extends": "../tsconfig",
  "compilerOptions": {
    "jsx": "react",
    "isolatedModules": false,
    "noEmit": false
  }
}
```

至此一切都完成了。

运行storybook时若出现错误： `Error: Cannot find module '@emotion/core/package.json'`，则手动安装一下： `yarn add --dev @emotion/core`
