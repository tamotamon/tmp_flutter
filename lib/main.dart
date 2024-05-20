import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //20240519_deleta_Vercel.json対応
  //.envファイルを読み込む設定.
  await dotenv.load(fileName: 'env');

  // Supabaseを初期化. .envファイルからURLとanonKeyを取得して設定.
  await Supabase.initialize(
    url: dotenv.get('VAR_URL'),
    anonKey: dotenv.get('VAR_ANONKEY'),
  );
  //eof_20240519_deleta_Vercel.json対応
  
  // // 20240519_add_Vercel.json対応_ビルド時に設定された環境変数を読み込む
  // const varUrl = String.fromEnvironment('VAR_URL', defaultValue: '');
  // const varAnonKey = String.fromEnvironment('VAR_ANONKEY', defaultValue: '');

  // // Supabaseを初期化
  // await Supabase.initialize(
  //   url: varUrl,
  //   anonKey: varAnonKey,
  // );
  // --eof 

  // // 20240519_002 add Vecel.json 対応2回目//
  // await dotenv.load();

  // // 20240519_002_add_Vercel.json対応_ビルド時に設定された環境変数を読み込む
  // const varUrl = String.fromEnvironment('VAR_URL', defaultValue: '');
  // const varAnonKey = String.fromEnvironment('VAR_ANONKEY', defaultValue: '');

  // // 20240519_002_add_Supabaseを初期化
  // await Supabase.initialize(
  //   url: varUrl,
  //   anonKey: varAnonKey,
  // );
  // // 20240519_002_eof

  // Flutterアプリを起動.
  runApp(const FlutterTestApp());
}

// メインのFlutterアプリケーションクラス.
class FlutterTestApp extends StatelessWidget {
  const FlutterTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home333',
      // 20240519_002_Vercel.json対応
      home: const HomePage(),  // ホーム画面としてHomePageを指定.
    );
  }
}

// HomePageクラスとその状態管理クラス.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Supabaseのストリームを設定してデータベースの変更をリアルタイムで監視.
  final _carMaintenanceStream = Supabase.instance.client
      .from('t_car_maintenance')
      .stream(primaryKey: ['id']);

  // フォームの入力値を保存するためのコントローラー.
  final TextEditingController _body = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
      ),
      // StreamBuilderを使用してリアルタイムでデータの変更を反映.
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _carMaintenanceStream,
        builder: (context, snapshot) {
          // データがまだ読み込まれていない場合、プログレスインジケーターを表示.
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 取得したデータをリストで表示.
          final carMaintenance = snapshot.data!;

          return ListView.builder(
            itemCount: carMaintenance.length,
            itemBuilder: (context, index) {
              final item = carMaintenance[index];
              final body = item['content'] as String?;
              final createdAt = item['created_at'] as String?;

              return ListTile(
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      // 編集ボタン
                      IconButton(
                        onPressed: () async {
                          // ダイアログを表示してノートの編集を行う.
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: const Text('Add a Note'),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                                children: [
                                  TextFormField(
                                    controller: _body,  // 入力フォームのコントローラーを設定.
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // データベースの内容を更新する処理.
                                      await Supabase.instance.client
                                          .from('t_car_maintenance')
                                          .update({'content': _body.text})
                                          .match({'id': item['id']});
                                      Navigator.of(context).pop();  // ダイアログを閉じる.
                                    },
                                    child: const Text('Put'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.blueAccent,
                        ),
                      ),
                      // 削除ボタン
                      IconButton(
                        onPressed: () async {
                          // 選択したアイテムをデータベースから削除する処理.
                          await Supabase.instance.client
                              .from('t_car_maintenance')
                              .delete()
                              .match({'id': item['id']});
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Text(body ?? 'No body'), // ノートの内容を表示.
                subtitle: Text(createdAt ?? 'No date'), // 作成された日時を表示.
              );
            },
          );
        },
      ),
      // 追加ボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ダイアログを表示して新しいノートを追加する処理.
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('Add a Note'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                children: [
                  TextFormField(
                    controller: _body,  // 入力フォームのコントローラーを設定.
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // 新しいノートをデータベースに追加する処理.
                      await Supabase.instance.client
                          .from('t_car_maintenance')
                          .insert({'content': _body.text});
                      Navigator.of(context).pop();  // ダイアログを閉じる.
                    },
                    child: const Text('Post'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
