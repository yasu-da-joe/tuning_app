const { environment } = require('@rails/webpacker')

// エントリーポイントの設定を追加
environment.config.entry = {
  application: './app/javascript/packs/application.js'
}

module.exports = environment