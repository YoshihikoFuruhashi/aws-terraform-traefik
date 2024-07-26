# TerraformとDockerを使用したTraefikデモセットアップ

このリポジトリには、TerraformとDocker Composeを使用してAWS上にTraefikデモ環境をセットアップするためのコードが含まれています。

## 必要条件

- Terraformがインストールされていること
- AWS CLIがインストールおよび設定されていること
- AWS EC2用のSSHキーペア

## ファイル構成

- `main.tf`: Terraformの構成ファイル
- `setup.sh`: EC2インスタンス上でDockerとDocker Composeをセットアップするスクリプト
- `stack.yml`: Traefik用のDocker Composeファイル

## 手順

1. リポジトリをクローンします:
   ```bash
   git clone https://github.com/yourusername/traefik-demo-setup.git
   cd traefik-demo-setup
