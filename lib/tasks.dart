import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:planner/misc/duration_format.dart';
import 'package:planner/misc/generate_plan.dart';
import 'package:planner/misc/get_data.dart';
import 'package:planner/misc/colors.dart';
import 'package:planner/misc/fonts.dart';
import 'package:planner/add_tasks.dart';
import 'package:flutter/material.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> with AutomaticKeepAliveClientMixin {
  // This is preserving the state of this screen
  @override
  bool get wantKeepAlive => true;
    
  // Outer list
  late List<DragAndDropList> contents;

  final ScrollController _scrollController = ScrollController();

  // This is in didChangeDependencies because when it was in initState it generated a
  // weird error
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initializing a list
    contents = [
      DragAndDropList(
        contentsWhenEmpty: Container(),
        canDrag: false,
        header: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Text("Must do", style: regularBoldFont.copyWith(color: forthColor)),
        ),
        children: GetData.savedTasks.where(
          (element) => element.importance == 3
        ).map(
          (e) => DragAndDropItem(
            child: MyListItem(
              data: e, 
              add: add, 
              remove: remove, 
              change: change, 
              look: look
            )
          )
        ).toList(),
      ),
      DragAndDropList(
        contentsWhenEmpty: Container(),
        canDrag: false,
        header: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Text("Urgent", style: regularBoldFont.copyWith(color: forthColor)),
        ),
        children: GetData.savedTasks.where(
          (element) => element.importance == 2
        ).map(
          (e) => DragAndDropItem(
            child: MyListItem(
              data: e, 
              add: add, 
              remove: remove, 
              change: change, 
              look: look
            )
          )
        ).toList(),
      ),
      DragAndDropList(
        contentsWhenEmpty: Container(),
        canDrag: false,
        header: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Text("Low priority", style: regularBoldFont.copyWith(color: forthColor)),
        ),
        children: GetData.savedTasks.where(
          (element) => element.importance == 1
        ).map(
          (e) => DragAndDropItem(
            child: MyListItem(
              data: e, 
              add: add, 
              remove: remove, 
              change: change, 
              look: look
            )
          )
        ).toList(),
      ),
      DragAndDropList(
        contentsWhenEmpty: Container(),
        canDrag: false,
        header: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Text("Not much important", style: regularBoldFont.copyWith(color: forthColor)),
        ),
        children: GetData.savedTasks.where(
          (element) => element.importance == 0
        ).map(
          (e) => DragAndDropItem(
            child: MyListItem(
              data: e, 
              add: add, 
              remove: remove, 
              change: change, 
              look: look
            )
          )
        ).toList(),
      ),
    ];
  
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: SizedBox(
        height: 45,
        width: 45,
        child: FloatingActionButton(
          backgroundColor: secondaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return AddTasks(
                    add: add,
                    remove: remove,
                    change: change,
                    look: look,
                  );
                },
              ),
            );
          },
          child: Icon(Icons.add, color: mainColor),
        ),
      ),
      backgroundColor: mainColor,
      // This is for the top banner, without CustomScrollView I wouldn't be able to
      // add it in DragAndDropLists
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // The top banner with info
          SliverAppBar(
            toolbarHeight: 85,
            titleSpacing: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                height: 85,
                decoration: BoxDecoration(
                  color: thirdColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Double tap to edit or remove a task. Each task is sorted into a group based on its importance. Drag by the handle to move a task into a different group.",
                    style: smallFont,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                  ),
                ),
              ),
            ),
          ),
          // The list
          SliverPadding(
            padding: const EdgeInsets.only(top: 20),
            sliver: DragAndDropLists(
              // The bottom padding in a group
              lastItemTargetHeight: 15,
              // The padding at the bottom of the page
              lastListTargetSize: 100,
              // The padding in between groups
              listDivider: const SizedBox(height: 20),
              // To remove the listDivider padding beneath the last group
              listDividerOnLastChild: false,
              // The padding between list items
              itemDivider: const SizedBox(height: 15),
              // The horizontal padding of the whole page
              listPadding: const EdgeInsets.symmetric(horizontal: 25),
              listDecoration: BoxDecoration(
                  color: thirdColor, borderRadius: BorderRadius.circular(25)),
              children: contents,
              itemDragOnLongPress: false,
              itemDragHandle: DragHandle(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(Icons.drag_handle_rounded, color: grey, size: 25),
                ),
              ),
              onItemReorder: onItemReorder,
              // This is null, because I don't use list reordering
              onListReorder: (a, b) {},
              // This is so that I can have a custom banner at the top
              sliverList: true,
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }

  // Reordering items when one of them is dragged to a different group
  onItemReorder(
    int oldItemIndex, 
    int oldListIndex, 
    int newItemIndex, 
    int newListIndex,
  ) {
    setState(() {
      var movedItem = contents[oldListIndex].children.removeAt(oldItemIndex);
      int index = GetData.savedTasks.indexWhere(
        (element) => element.key == (movedItem.child as MyListItem).data.key
      );
      var newData = TaskData(
        name: GetData.savedTasks[index].name, 
        duration: GetData.savedTasks[index].duration, 
        importance: contents.length - 1 - newListIndex, 
        key: GetData.savedTasks[index].key,
        everydayTask: GetData.savedTasks[index].everydayTask,
        everydayTaskTime: GetData.savedTasks[index].everydayTaskTime,
        oneTimeTask: GetData.savedTasks[index].oneTimeTask,
      );
      contents[newListIndex].children.insert(
        newItemIndex,
        DragAndDropItem(
          child: MyListItem(
            data: newData, 
            add: add, 
            remove: remove, 
            change: change, 
            look: look
          ) 
        ) 
      );
      var temp = [...GetData.savedTasks]; 
      temp[index] = newData;
      GetData.savedTasks = temp;
    });

    // Updating the plan
    refreshPlan();
  }

  void add(DragAndDropItem item, int importance){
    setState(() {
      contents[contents.length - 1 - importance].children.add(item);
    });
  }

  void remove(int importance, int index){
    setState(() {
      contents[contents.length - 1 - importance].children.removeAt(index);
    });
  }

  void change(int importance, int index, DragAndDropItem item){
    setState(() {
      contents[contents.length - 1 - importance].children[index] = item;
    });
  }

  List<int> look(Key key){
    int listIndex = contents.indexWhere(
      (element) {
        return element.children.any((e) => (e.child as MyListItem).data.key == key);
      }
    );

    int index = contents[listIndex].children.indexWhere(
      (element) {
        return (element.child as MyListItem).data.key == key;
      }
    );

    return [contents.length - 1 - listIndex, index];
  }

}


class MyListItem extends StatefulWidget {
  const MyListItem({
    super.key, 
    required this.data,
    required this.add,
    required this.remove,
    required this.change,
    required this.look,
  });

  final TaskData data;
  final Function(DragAndDropItem, int) add;
  final Function(int, int) remove;
  final Function(int, int, DragAndDropItem) change;
  final List<int> Function(Key) look; 

  @override
  State<MyListItem> createState() => _MyListItemState();
}

class _MyListItemState extends State<MyListItem> {
  @override
  Widget build(BuildContext context) {
    Widget temp = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onDoubleTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return AddTasks(
                      data: widget.data,
                      add: widget.add,
                      remove: widget.remove,
                      change: widget.change,
                      look: widget.look,
                    );
                  },
                ),
              );
            },
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 240
                  ),
                  child: Text(widget.data.name, style: regularFont, overflow: TextOverflow.clip)
                ),
                const SizedBox(height: 5),
                Text("Duration: ${formatDuration(widget.data.duration)}",
                    style: smallFont),
                if (widget.data.everydayTask) const SizedBox(height: 5),
                if (widget.data.everydayTask)
                  Text("Repeat everyday at: ${widget.data.everydayTaskTime!.format(context)}",
                      style: smallFont),
                if (widget.data.oneTimeTask) const SizedBox(height: 5),
                if (widget.data.oneTimeTask) Text("One time task", style: smallFont),
              ],
            ),
          ),
        ],
      ),
    );

    return temp;
  }
}