## PoppingOutCell

PoppingOutCell is a small plug-in for iOS. It can bring wonderful experience when gently dragging cell to left.

## Architecture

- `DraggedTableViewCell`
- `PopOutButtonViewCell`
- `CellView`
- `TableCellData`
- `PrefixHeader`

## Usage

### import essential header into your View Controller

```objective-c
#import "DraggedTableViewCell.h"
#import "PopOutButtonView.h"
```
"PopOutButtonView.h" can be changed to whatever button styles you like.

### use PopOutButtonViewCell in your cellForRowAtIndexPath delegate

```objective-c
DraggedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
```

### add buttons to cell

```objective-c
PopOutButtonView *view = [[PopOutButtonView alloc] initWithFrame:Frame
                                                        andTitle:nil
                                              andBackgroundColor:[UIColor color]];
[cell addSubviewAsPopOutButton:view];
```
