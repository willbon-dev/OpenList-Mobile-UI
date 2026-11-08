/// 服务器任务（/api/task/{cat}/*）：离线下载、上传、复制、移动、解压。
class TaskInfo {
  final Map<String, dynamic> raw;

  TaskInfo(this.raw);

  String get id => raw['id'] as String? ?? '';
  String get name => raw['name'] as String? ?? '';
  String get state => raw['state'] as String? ?? '';
  String get status => raw['status'] as String? ?? '';
  double get progress => (raw['progress'] as num?)?.toDouble() ?? 0;
  int get totalBytes => (raw['total_bytes'] as num?)?.toInt() ?? 0;
  String get error => raw['error'] as String? ?? '';
}

/// 服务器任务分类
enum TaskCategory {
  offlineDownload('offline_download', '离线下载'),
  upload('upload', '上传'),
  copy('copy', '复制'),
  move('move', '移动'),
  decompress('decompress', '解压');

  const TaskCategory(this.apiCat, this.label);
  final String apiCat;
  final String label;
}

/// 任务状态中文展示
String taskStateLabel(String state) {
  switch (state) {
    case 'pending':
      return '等待中';
    case 'running':
      return '进行中';
    case 'succeeded':
      return '已完成';
    case 'failed':
    case 'errored':
      return '失败';
    case 'failing':
      return '失败中';
    case 'canceled':
      return '已取消';
    case 'canceling':
      return '取消中';
    case 'before_retry':
    case 'waiting_retry':
      return '等待重试';
    case 'retrying':
      return '重试中';
    default:
      return state;
  }
}
