# Env Replace Action

替换配置文件（如`.env`文件）中的预设值（如`APP_URL`）为当前环境中的配置值（如`http://abc.com`）。

## 场景

一些敏感的数据（如：DB_PASSWORD）不能存储在代码仓库中，可将其存储在生产服务器上，部署时设置真实值。

## 输入参数

### `host`

**必须**   
远程服务器地址。  
如：`8.8.8.8`

### `key`

**必须**   
使用SSH连接远程服务器时的私钥。  
如：`${{ secrets.DEPLOY_KEY }}`

### `remote_script`

**必须**   
远程服务器上配置变量的脚本。  
如：`/www/set_env.sh`，文件内容：
```text
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=love
DB_USERNAME=root
DB_PASSWORD=password
FOO=BAR
```

### `target`

**可选**，默认：`.env`   
当前项目中的需要替换预设值的配置文件。  
如：`.env`，文件内容：
```text
DB_HOST={{DB_HOST}}
DB_PORT={{DB_PORT}}
DB_DATABASE={{DB_DATABASE}}
DB_USERNAME={{DB_USERNAME}}
DB_PASSWORD={{DB_PASSWORD}}
FOO=ABC
```

## 例子

当前项目的`.env`文件：
```text
DB_HOST={{DB_HOST}}
DB_PORT={{DB_PORT}}
DB_DATABASE={{DB_DATABASE}}
DB_USERNAME={{DB_USERNAME}}
DB_PASSWORD={{DB_PASSWORD}}
FOO=ABC
```

远程服务器中的`/www/set_env.sh`文件

```text
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=love
DB_USERNAME=root
DB_PASSWORD=password
FOO=BAR
```

GitHub Action流程文件：
```yaml
- uses: actions/checkout@v2
- uses: nookery/env-replace-action@main
  env:
    APP_URL: abc.com
  with:
    host: 8.8.8.8
    key: ${{ secrets.DEPLOY_KEY }} # 引用配置，SSH私钥
    remote_script: /www/set_env.sh
```

替换后的当前项目的`.env`文件：
```text
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=love
DB_USERNAME=root
DB_PASSWORD=password
FOO=ABC
```
