# sso-by-saml-sample-app

- EC2(Amazon Linux 2)にインストールすることを前提としています
- ポート80で起動させたかったので、`root` ユーザでの起動を前提としています

### Rubyをインストール

```sh
amazon-linux-extras list | grep ruby
  #  13  ruby2.4                  available    [ =2.4.2  =2.4.4 ]

amazon-linux-extras install -y ruby2.4ruby

ruby -v
  # ruby 2.4.4p296 (2018-03-28 revision 63013) [x86_64-linux]
gem -v
  # 2.6.14.1
```

### bundlerをインストール

```sh
gem install --no-ri --no-rdoc bundler
  # Successfully installed bundler-2.0.1
  # 1 gem installed

bundler -v
  # Bundler version 2.0.1
```

### 関連するライブラリをインストール

```sh
yum -y install \
  ruby-devel gcc gcc-c++ system-rpm-config \
  zlib-devel libxml2-devel libxslt-devel \
  mariadb mariadb-devel mariadb-server
```

### データベースを起動

```sh
systemctl start mariadb
systemctl enable mariadb
```

### セットアップ

```sh
bundle config build.nokogiri --use-system-libraries
bundle install --path vendor/bundle
bundle exec rake db:create
bundle exec rake db:migrate
```

### `.env` ファイルの設定

|変数名|設定値|
|--|--|
|DEVISE_DEFAULT_URL_OPTIONS|パスワードを忘れた際に送信するメールのリダイレクト先のURLを指定<br>default: `localhost:3000`|
|BETTER_ERRORS_ALLOW_IP|`better_errors` は開発環境がリモート環境の場合に動作しないため、動作を許可させるIPアドレスを指定<br>default: `127.0.0.1`|
|OPENAM_URI|OpenAMのURIを指定<br>default: `http://localhost:3000/openam`|
|OPENAM_ADMIN_USER|OpenAMのAdminユーザのユーザ名<br>default: `amAdmin`|
|OPENAM_ADMIN_PASS|OpenAMのAdminユーザのパスワード<br>default: `password`|
|OPENAM_AWS_ROLE_ARN|OpenAMユーザがログインする際のAWSロールのARN|
|OPENAM_AWS_ID_PROVIDER_ARN|OpenAMユーザのロールの信頼されたエンティティのARN|

### 起動

```sh
bundle exec rails s -b 0.0.0.0 -p 80
```
