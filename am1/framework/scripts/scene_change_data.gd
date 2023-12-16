class_name SceneChangeData
extends RefCounted

## Scene Change Data
##
## SceneChangerにシーン切り替えを要求するときに渡すデータ

## 画面を覆う情報
var screen_cover: String
var cover_color: Color
var cover_seconds: float

## 非同期で読み込むシーンの配列
var async_load_scenes: Array[String]

## 解放するシーンの配列
var release_scenes: Array[String]

## 同期読み込みするシーンの配列
var sync_load_scenes: Array[String]

