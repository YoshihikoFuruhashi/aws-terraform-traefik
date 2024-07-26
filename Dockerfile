FROM traefik:v2.4

# ポートの公開
EXPOSE 80
EXPOSE 8080

# Traefikの設定
CMD ["--api.insecure=true", "--providers.docker"]

