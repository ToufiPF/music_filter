
enum MenuAction {
  addToPlaylist("Add to playlist"),
  removeFromPlaylist("Remove from playlist"),
  export("Export"),
  delete("Delete");

  const MenuAction(this.text);

  final String text;
}

class MusicContextMenu {

}
