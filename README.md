# Bluetooth LE 操作アプリ

## はじめに

[逆引きSwift](http://docs.fabo.io/swift/)に公開されている[CoreBluetooth](http://docs.fabo.io/swift/corebluetooth/)>[006 操作アプリ](http://docs.fabo.io/swift/corebluetooth/006_corebluetooth.html)で公開されているサンプルコードをSwiftUI化しました。



## ファイルの構成

このサンプルプロジェクトは下記のような構成になっています。

| ファイル名               | 概要                                                         |
| ------------------------ | ------------------------------------------------------------ |
| ContentView.swift        | トップ画面<BR>検索ボタンを押すとペリフェラル一覧が表示されます。<BR>リストをタップすると検索を中止し、対象デバイスの接続処理を行います。 |
| ServiceListView.swift    | サービスリスト画面<BR>接続されたデバイスのサービスリストを取得し一覧表示します。<BR>リストをタップすると、Characteristic読み込み書き込み画面に遷移します。 |
| ServiceControlView.swift | Characteristic読み込み書き込み画面<BR>Readボタンを押すとデバイスより取得したCharacteristicを表示します。<BR>（バイナリーの場合は受信したバイト数が表示されます）<BR>Writeボタンを押すとテキストフィールドの内容をデバイスに書き込みします。<BR>*注意エラーが発生してもポップアップ表示しません* |
| ListRowView.swift        | リスト表示の１行内のデザインをここで定義しています           |
| PeripheralVM.swift       | CoreBluetoothの処理部<BR>ObservableObjectを利用しUIの更新をしています |

