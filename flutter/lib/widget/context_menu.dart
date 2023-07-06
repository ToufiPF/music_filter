enum MenuAction {
  startFiltering("Start filtering"),
  removeFromPlaylist("Remove from playlist"),
  export("Export"),
  restore("Restore"),
  delete("Delete"),
  ;

  const MenuAction(this.text);

  final String text;
}

class MusicContextMenu {}
