enum ActionTypes {
  clear,
  addGlossary,
  addGlossaryItem,
  updateGlossary,
  updateGlossaryItem,
  loadGlossarys,
  loadGlossaryEntrys,
  removeGlossary,
  removeGlossaryItem,
}

class Action {
  final ActionTypes type;
  final dynamic payload;

  Action(this.type, {this.payload});
}