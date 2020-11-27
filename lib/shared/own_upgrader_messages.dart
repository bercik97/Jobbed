import 'package:upgrader/upgrader.dart';

class OwnUpgraderMessages extends UpgraderMessages {
  String titleMsg;
  String bodyMsg;
  String promptMsg;
  String buttonTitleIgnoreMsg;
  String buttonTitleUpdateMsg;

  OwnUpgraderMessages(this.titleMsg, this.bodyMsg, this.promptMsg, this.buttonTitleIgnoreMsg, this.buttonTitleUpdateMsg);

  @override
  String get title => titleMsg;

  @override
  String get body => bodyMsg;

  @override
  String get prompt => promptMsg;

  @override
  String get buttonTitleIgnore => buttonTitleIgnoreMsg;

  @override
  String get buttonTitleUpdate => buttonTitleUpdateMsg;
}
