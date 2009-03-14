{
  Taken from http://www.stevetrefethen.com/files/googlemap.zip
  which is linked from http://www.stevetrefethen.com/blog/UsingGoogleMapsFromVCLSampleApplication.aspx

  and explained at http://www.stevetrefethen.com/blog/CallingWindowsClientCodeFromJavascriptHostedInsideTheWebBrowserControl.aspx
}

unit Automation;

interface

uses Windows, SysUtils, Classes, Contnrs, TypInfo, ObjAuto, ObjComAuto,
  Graphics, Controls, Forms, Menus, StdCtrls, ComCtrls, CheckLst, Tabs, Grids;

type
  TAutoObjectDispatch = class(TObjectDispatch)
  protected
    function GetObjectDispatch(Obj: TObject): TObjectDispatch; override;
    function GetMethodInfo(const AName: ShortString; var AInstance: TObject): PMethodInfoHeader; override;
    function GetPropInfo(const AName: string; var AInstance: TObject; var CompIndex: Integer): PPropInfo; override;
  end;

{$METHODINFO ON}
  TObjectWrapper = class;
{$METHODINFO OFF}
  TObjectWrapperClass = class of TObjectWrapper;

  TClassMap = class(TObjectList)
  public
    procedure AddClass(AClass: TClass; AObjWrapper: TObjectWrapperClass);
    procedure RemoveClass(AClass: TClass; AObjWrapper: TObjectWrapperClass);
    function FindObjectWrapper(AClass: TClass): TObjectWrapperClass;
  end;

  { TObjectWrapper }

{$METHODINFO ON}
  TObjectWrapper = class(TObject)
  private
    function GetClassName: string;
    function GetParentClass: string;
  protected
    FObject: TObject;
  public
    constructor Connect(AObject: TObject); virtual;
    function InheritsFrom(const ClassName: string): Boolean;
  published
    property ParentClass: string read GetParentClass;
  {$WARNINGS OFF}
    property ClassName: string read GetClassName;
  {$WARNINGS ON}
  end;

  TPointClass = class;

  TRectClass = class
  private
    FRect: TRect;
    function GetBottomRight: TPointClass;
    function GetTopLeft: TPointClass;
  public
    constructor Create(const ARect: TRect);
  published
    property Top: Integer read FRect.Top write FRect.Top;
    property Left: Integer read FRect.Left write FRect.Left;
    property Right: Integer read FRect.Right write FRect.Right;
    property Bottom: Integer read FRect.Bottom write FRect.Bottom;
    property TopLeft: TPointClass read GetTopLeft;
    property BottomRight: TPointClass read GetBottomRight;
  end;

  TPointClass = class
  private
    FPoint: TPoint;
  public
    constructor Create(const APoint: TPoint);
  published
    property X: Integer read FPoint.X write FPoint.X;
    property Y: Integer read FPoint.Y write FPoint.Y;
  end;

{$METHODINFO OFF}

{ TRectPointWrapper }

  TRectPointWrapper = class(TObjectWrapper)
  public
    destructor Destroy; override;
  end;

{ TComponentWrapper }

  TComponentWrapper = class(TObjectWrapper)
  private
    function GetComponentCount: Integer;
    function GetComponentIndex: Integer;
    function GetOwner: TComponent;
    function GetDesignInfo: LongInt;
  public
    function GetComponent(Index: Integer): TComponent;
    function FindComponent(const AName: string): TComponent;
  published
    property ComponentCount: Integer read GetComponentCount;
    property ComponentIndex: Integer read GetComponentIndex;
    property DesignInfo: LongInt read GetDesignInfo;
    property Owner: TComponent read GetOwner;
  end;

{ TControlWrapper }

  TControlWrapper = class(TComponentWrapper)
  private
    function GetEnabled: Boolean;
    function GetParent: TWinControl;
    function GetText: string;
    function GetVisible: Boolean;
    procedure SetEnabled(value: Boolean);
    procedure SetText(const Value: string);
    procedure SetVisible(Value: Boolean);
  published
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property Parent: TWinControl read GetParent;
    property Text: string read GetText write SetText;
    property Visible: Boolean read GetVisible write SetVisible;
  end;

{ TWinControlWrapper }

  TWinControlWrapper = class(TControlWrapper)
  private
    function GetHandle: Integer;
    function GetControlCount: Integer;
  public
    function ControlAtPos(X, Y: Integer): TControl;
    function GetControls(Index: Integer): TControl;
    function HandleAllocated: Boolean;
  published
    property Handle: Integer read GetHandle;
    property ControlCount: Integer read GetControlCount;
  end;

{ TMemoWrapper }

  TMemoWrapper = class(TWinControlWrapper)
  private
    function GetLines: TStrings;
  published
    property Lines: TStrings read GetLines;
  end;

{ TScreenWrapper }

  TScreenWrapper = class(TComponentWrapper)
  private
    function GetFormCount: Integer;
  public
    function GetForm(Index: Integer): TCustomForm;
  published
    property FormCount: Integer read GetFormCount;
  end;

{ TApplicationWrapper }

  TApplicationWrapper = class(TComponentWrapper)
  private
    function GetHandle: Integer;
    function GetMainForm: TCustomForm;
    function GetExeName: string;
    function GetScreen: TScreen;
  public
    constructor Connect(AObject: TObject); override;
    function GetObjFromHandle(Handle: Integer): TObject;
  published
    property Handle: Integer read GetHandle;
    property MainForm: TCustomForm read GetMainForm;
    property ExeName: string read GetExeName;
    property Screen: TScreen read GetScreen;
  end;

{ TCollectionItemWrapper }

  TCollectionItemWrapper = class(TObjectWrapper)
  private
    function GetIndex: Integer;
    function GetID: Integer;
  published
    property Index: Integer read GetIndex;
    property ID: Integer read GetID;
  end;

{ TCollectionWrapper }

  TCollectionWrapper = class(TObjectWrapper)
  private
    function GetCount: Integer;
  public
    function GetItems(Index: Integer): TCollectionItem;
  published
    property Count: Integer read GetCount;
  end;

{ TTabSheetWrapper }

  TTabSheetWrapper = class(TWinControlWrapper)
  private
    function GetTabIndex: Integer;
  published
    property TabIndex: Integer read GetTabIndex;
  end;

{ TCustomTabControlWrapper }

  TCustomTabControlWrapper = class(TWinControlWrapper)
  private
    function GetTabs: TStrings;
  public
    function GetTabRect(Index: Integer): TRectClass;
  published
    property Tabs: TStrings read GetTabs;
  end;

{ TCustomTreeViewWrapper }

  TCustomTreeViewWrapper = class(TWinControlWrapper)
  private
    function GetSelected: TTreeNode;
  published
    property Selected: TTreeNode read GetSelected;
  end;

{ TTreeNodesWrapper }

  TTreeNodesWrapper = class(TObjectWrapper)
  private
    function GetCount: Integer;
  public
    function GetItem(Index: Integer): TTreeNode;
  published
    property Count: Integer read GetCount;
  end;

{ TTreeNodeWrapper }

  TTreeNodeWrapper = class(TObjectWrapper)
  private
    function GetCount: Integer;
    function GetText: String;
    function GetSelectedIndex: Integer;
    function GetSelected: Boolean;
    function GetExpanded: Boolean;
    function GetHasChildren: Boolean;
    function GetIsVisible: Boolean;
    function GetIndex: Integer;
    function GetFocused: Boolean;
    function GetLevel: Integer;
    procedure SetText(const Value: string);
    procedure SetExpanded(const Value: Boolean);
    procedure SetFocused(Value: Boolean);
    procedure SetSelected(Value: Boolean);
  public
    function GetItem(Index: Integer): TTreeNode;
    procedure Expand(Recurse: Boolean);
  published
    property Count: Integer read GetCount;
    property Text: String read GetText write SetText;
    property SelectedIndex: Integer read GetSelectedIndex;
    property Selected: Boolean read GetSelected write SetSelected;
    property Expanded: Boolean read GetExpanded write SetExpanded;
    property HasChildren: Boolean read GetHasChildren;
    property IsVisible: Boolean read GetIsVisible;
    property Index: Integer read GetIndex;
    property Focused: Boolean read GetFocused write SetFocused;
    property Level: Integer read GetLevel;
  end;

{ TCustomListViewWrapper }

  TCustomListViewWrapper = class(TWinControlWrapper)
  end;

{ TListItemWrapper }

  TListItemWrapper = class(TObjectWrapper)
  private
    function GetSubItems: TStrings;
    function GetCaption: String;
    function GetFocused: Boolean;
    function GetIndent: Integer;
    function GetIndex: Integer;
    function GetSelected: Boolean;
    function GetLeft: Integer;
    function GetTop: Integer;
    procedure SetCaption(const Value: string);
    procedure SetFocused(Value: Boolean);
    procedure SetIndent(Value: Integer);
    procedure SetSelected(Value: Boolean);
  published
    property SubItems: TStrings read GetSubItems;
    property Caption: String read GetCaption write SetCaption;
    property Focused: Boolean read GetFocused write SetFocused;
    property Indent: Integer read GetIndent write SetIndent;
    property Index: Integer read GetIndex;
    property Selected: Boolean read GetSelected write SetSelected;
    property Left: Integer read GetLeft;
    property Top: Integer read GetTop;
  end;

{ TListItemsWrapper }

  TListItemsWrapper = class(TObjectWrapper)
  private
    function GetCount: Integer;
  published
    function GetItem(Index: Integer): TListItem;
    property Count: Integer read GetCount;
  end;

{ THeaderSectionWrapper }

  THeaderSectionWrapper = class(TCollectionItemWrapper)
  private
    function GetLeft: Integer;
    function GetRight: Integer;
  published
    property Left: Integer read GetLeft;
    property Right: Integer read GetRight;
  end;

{ TStatusPanelWrapper }

  TStatusPanelWrapper = class(TCollectionItemWrapper)
  end;

{ TCustomGridWrapper }

  TCustomGridWrapper = class(TWinControlWrapper)
  public
    function GetCellRect(ACol, ARow: Integer): TRectClass;
  end;

{ TStringGridWrapper }

  TStringGridWrapper = class(TCustomGridWrapper)
  public
    function GetCells(ACol, ARow: Integer): string;
  end;

{ TMenuWrapper }

  TMenuWrapper = class(TComponentWrapper)
  private
    function GetHandle: Integer;
  public
    property Handle: Integer read GetHandle;
    function FindItem(Index: Integer): TMenuItem;
  end;

{ TMenuItemWrapper }

  TMenuItemWrapper = class(TComponentWrapper)
  private
    function GetHandle: Integer;
    function GetMenuItemIndex: Integer;
    function GetCount: Integer;
    function GetCommand: Integer;
    function GetParent: TMenuItem;
  public
    function GetItems(Index: Integer): TMenuItem;
    procedure Click;
  published
    property Handle: Integer read GetHandle;
    property MenuItemIndex: Integer read GetMenuItemIndex;
    property Count: Integer read GetCount;
    property Command: Integer read GetCommand;
    property Parent: TMenuItem read GetParent;
  end;

{ TCustomListboxWrapper }

  TCustomListboxWrapper = class(TWinControlWrapper)
  end;

{ TCheckListBoxWrapper }

  TCheckListBoxWrapper = class(TCustomListBoxWrapper)
  public
    function GetChecked(Index: Integer): Boolean;
    function GetState(Index: Integer): TCheckBoxState;
    function GetHeader(Index: Integer): Boolean;
    function GetItemEnabled(Index: Integer): Boolean;
    procedure SetChecked(Index: Integer; Value: Boolean);
    procedure SetState(Index: Integer; Value: TCheckBoxState);
    procedure SetHeader(Index: Integer; Value: Boolean);
    procedure SetItemEnabled(Index: Integer; Value: Boolean);
  end;

{ TTabSetWrapper }

  TTabSetWrapper = class(TWinControlWrapper)
  public
    function GetItemRect(Item: Integer): TRectClass;
  end;

{ TStringsWrapper }

  TStringsWrapper = class(TObjectWrapper)
  private
    function GetCount: Integer;
  public
    function GetStrings(Index: Integer): string;
    function GetObjects(Index: Integer): TObject;
    function Add(const Item: string): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    function IndexOf(const Item: string): Integer;
  published
    property Count: Integer read GetCount;
  end;

{ TPictureWrapper }

  TPictureWrapper = class(TObjectWrapper)
  private
    function GetBitmap: TBitmap;
    function GetGraphic: TGraphic;
    function GetHeight: Integer;
    function GetIcon: TIcon;
    function GetWidth: Integer;
  published
    property Bitmap: TBitmap read GetBitmap;
    property Graphic: TGraphic read GetGraphic;
    property Height: Integer read GetHeight;
    property Icon: TIcon read GetIcon;
    property Width: Integer read GetWidth;
  end;

{ TGraphicWrapper }

  TGraphicWrapper = class(TObjectWrapper)
  private
    function GetHeight: Integer;
    function GetModified: Boolean;
    function GetTransParent: Boolean;
    function GetWidth: Integer;
  published
    property Height: Integer read GetHeight;
    property Modified: Boolean read GetModified;
    property Transparent: Boolean read GetTransparent;
    property Width: Integer read GetWidth;
  end;

{ TBitmapWrapper }

  TBitmapWrapper = class(TGraphicWrapper)
  private
    function GetHeight: Integer;
    function GetHandleType: TBitmapHandleType;
    function GetMonochrome: Boolean;
    function GetTransparentColor: Integer;
    function GetWidth: Integer;
  published
    property HandleType: TBitmapHandleType read GetHandleType;
    property Height: Integer read GetHeight;
    property Monochrome: Boolean read GetMonochrome;
    property TransparentColor: Integer read GetTransparentColor;
    property Width: Integer read GetWidth;
  end;

function ClassMap: TClassMap;

implementation

resourcestring
  sAppWrapperOnly = 'Automation wrapper for the Application can only be created with a TApplication';
  sClassAlreadyInMap = 'Class ''%s'', already in class map';

var
  FClassMap: TClassMap;

{ TAutoObjectDispatch }

function TAutoObjectDispatch.GetMethodInfo(const AName: ShortString; var AInstance: TObject): PMethodInfoHeader;
begin
  Result := inherited GetMethodInfo(AName, AInstance);
  if (Result = nil) and (Instance is TObjectWrapper) then
  begin
    Result := ObjAuto.GetMethodInfo(TObjectWrapper(Instance).FObject, AName);
    if Result <> nil then
    begin
      AInstance := TObjectWrapper(Instance).FObject;
      Exit;
    end;
  end;
end;

function TAutoObjectDispatch.GetObjectDispatch(Obj: TObject): TObjectDispatch;
var
  ObjWrap: TObjectWrapperClass;
begin
  ObjWrap := ClassMap.FindObjectWrapper(Obj.ClassType);
  if ObjWrap <> nil then
    Result := TAutoObjectDispatch.Create(ObjWrap.Connect(Obj), True)
  else
    Result := nil;
end;

function TAutoObjectDispatch.GetPropInfo(const AName: string; var AInstance: TObject;
  var CompIndex: Integer): PPropInfo;
var
  Component: TComponent;
begin
  Result := inherited GetPropInfo(AName, AInstance, CompIndex);
  if (Result = nil) and (Instance is TObjectWrapper) then
  begin
    Result := TypInfo.GetPropInfo(TObjectWrapper(Instance).FObject, AName);
    if Result <> nil then
    begin
      AInstance := TObjectWrapper(Instance).FObject;
      Exit;
    end else if TObjectWrapper(Instance).FObject is TComponent then
    begin
      // Not a property, try a sub component
      Component := TComponent(TObjectWrapper(Instance).FObject).FindComponent(AName);
      if Component <> nil then
      begin
        AInstance := TObjectWrapper(Instance).FObject;
        CompIndex := Component.ComponentIndex;
      end;
    end else
      AInstance := nil;
  end;
end;

function ClassMap: TClassMap;
begin
  if FClassMap = nil then
    FClassMap := TClassMap.Create;
  Result := FClassMap;
end;

{ TObjectWrapper }

constructor TObjectWrapper.Connect(AObject: TObject);
begin
  FObject := AObject;
end;

function TObjectWrapper.GetClassName: string;
begin
  Result := FObject.ClassName;
end;

function TObjectWrapper.GetParentClass: string;
begin
  if FObject.ClassParent <> nil then
    Result := FObject.ClassParent.ClassName
  else
    Result := '';
end;

function TObjectWrapper.InheritsFrom(const ClassName: string): Boolean;
var
  AClass: TClass;
begin
  AClass := FObject.ClassType;
  while (AClass <> nil) and not AClass.ClassNameIs(ClassName) do
    AClass := AClass.ClassParent;
  Result := AClass <> nil;
end;

type
  TControlCracker = class(TControl);

{ TComponentWrapper }

function TComponentWrapper.FindComponent(const AName: string): TComponent;
begin
  Result := TComponent(FObject).FindComponent(AName);
end;

function TComponentWrapper.GetComponentCount: Integer;
begin
  Result := TComponent(FObject).ComponentCount;
end;

function TComponentWrapper.GetComponentIndex: Integer;
begin
  Result := TComponent(FObject).ComponentIndex;
end;

function TComponentWrapper.GetComponent(Index: Integer): TComponent;
begin
  Result := TComponent(FObject).Components[Index];
end;

function TComponentWrapper.GetDesignInfo: LongInt;
begin
  Result := TComponent(FObject).DesignInfo;
end;

function TComponentWrapper.GetOwner: TComponent;
begin
  Result := TComponent(FObject).Owner;
end;

{ TControlWrapper }

function TControlWrapper.GetEnabled: Boolean;
begin
  Result := TControl(FObject).Enabled;
end;

function TControlWrapper.GetParent: TWinControl;
begin
  Result := TControl(FObject).Parent;
end;

function TControlWrapper.GetText: string;
begin
  Result := TControlCracker(FObject).Text;
end;

function TControlWrapper.GetVisible: Boolean;
begin
  Result := TControl(FObject).Visible;
end;

procedure TControlWrapper.SetEnabled(value: Boolean);
begin
  TControl(FObject).Enabled := Value;
end;

procedure TControlWrapper.SetText(const Value: string);
begin
  TControlCracker(FObject).Text := Value;
end;

procedure TControlWrapper.SetVisible(Value: Boolean);
begin
  TControl(FObject).Visible := Value;
end;

{ TWinControlWrapper }

function TWinControlWrapper.ControlAtPos(X, Y: Integer): TControl;
begin
  Result := TWinControl(FObject).ControlAtPos(Point(X, Y), True, False);
end;

function TWinControlWrapper.GetControlCount: Integer;
begin
  Result := TWinControl(FObject).ControlCount;
end;

function TWinControlWrapper.GetControls(Index: Integer): TControl;
begin
  Result := TWinControl(FObject).Controls[Index];
end;

function TWinControlWrapper.GetHandle: Integer;
begin
  Result := TWinControl(FObject).Handle;
end;

function TWinControlWrapper.HandleAllocated: Boolean;
begin
  Result := TWinControl(FObject).HandleAllocated;
end;

{ TApplicationWrapper }

constructor TApplicationWrapper.Connect(AObject: TObject);
begin
  if AObject <> Application then
    raise Exception.Create(sAppWrapperOnly);
  inherited;
end;

function TApplicationWrapper.GetExeName: string;
begin
  Result := TApplication(FObject).ExeName;
end;

function TApplicationWrapper.GetHandle: Integer;
begin
  Result := TApplication(FObject).Handle;
end;

function TApplicationWrapper.GetMainForm: TCustomForm;
begin
  Result := TApplication(FObject).MainForm;
end;

function TApplicationWrapper.GetObjFromHandle(Handle: Integer): TObject;
begin
  Result := FindControl(Handle);
end;

function TApplicationWrapper.GetScreen: TScreen;
begin
  Result := Forms.Screen;
end;

{ TCollectionItemWrapper }

function TCollectionItemWrapper.GetID: Integer;
begin
  Result := TCollectionItem(FObject).ID;
end;

function TCollectionItemWrapper.GetIndex: Integer;
begin
  Result := TCollectionItem(FObject).Index;
end;

{ TCollectionWrapper }

function TCollectionWrapper.GetCount: Integer;
begin
  Result := TCollection(FObject).Count;
end;

function TCollectionWrapper.GetItems(Index: Integer): TCollectionItem;
begin
  Result := TCollection(FObject).Items[Index];
end;

{ TTabSheetWrapper }

function TTabSheetWrapper.GetTabIndex: Integer;
begin
  Result := TTabSheet(FObject).TabIndex;
end;

{ TCustomTabControlWrapper }

type
  TCustomTabControlCracker = class(TCustomTabControl);

function TCustomTabControlWrapper.GetTabRect(Index: Integer): TRectClass;
begin
  Result := TRectClass.Create(TCustomTabControl(FObject).TabRect(Index));
end;

function TCustomTabControlWrapper.GetTabs: TStrings;
begin
  Result := TCustomTabControlCracker(FObject).Tabs;
end;

{ TCustomTreeViewWrapper }

function TCustomTreeViewWrapper.GetSelected: TTreeNode;
begin
  Result := TCustomTreeView(FObject).Selected;
end;

{ TTreeNodesWrapper }

function TTreeNodesWrapper.GetCount: Integer;
begin
  Result := TTreeNodes(FObject).Count;
end;

function TTreeNodesWrapper.GetItem(Index: Integer): TTreeNode;
begin
  Result := TTreeNodes(FObject).Item[Index];
end;

{ TTreeNodeWrapper }

procedure TTreeNodeWrapper.Expand(Recurse: Boolean);
begin
  TTreeNode(FObject).Expand(Recurse);
end;

function TTreeNodeWrapper.GetCount: Integer;
begin
  Result := TTreeNode(FObject).Count;
end;

function TTreeNodeWrapper.GetExpanded: Boolean;
begin
  Result := TTreeNode(FObject).Expanded;
end;

function TTreeNodeWrapper.GetFocused: Boolean;
begin
  Result := TTreeNode(FObject).Focused;
end;

function TTreeNodeWrapper.GetHasChildren: Boolean;
begin
  Result := TTreeNode(FObject).HasChildren;
end;

function TTreeNodeWrapper.GetIndex: Integer;
begin
  Result := TTreeNode(FObject).Index;
end;

function TTreeNodeWrapper.GetIsVisible: Boolean;
begin
  Result := TTreeNode(FObject).IsVisible;
end;

function TTreeNodeWrapper.GetItem(Index: Integer): TTreeNode;
begin
  Result := TTreeNode(FObject).Item[Index];
end;

function TTreeNodeWrapper.GetLevel: Integer;
begin
  Result := TTreeNode(FObject).Level;
end;

function TTreeNodeWrapper.GetSelected: Boolean;
begin
  Result := TTreeNode(FObject).Selected;
end;

function TTreeNodeWrapper.GetSelectedIndex: Integer;
begin
  Result := TTreeNode(FObject).SelectedIndex;
end;

function TTreeNodeWrapper.GetText: String;
begin
  Result := TTreeNode(FObject).Text;
end;

procedure TTreeNodeWrapper.SetExpanded(const Value: Boolean);
begin
  TTreeNode(FObject).Expanded := Value;
end;

procedure TTreeNodeWrapper.SetFocused(Value: Boolean);
begin
  TTreeNode(FObject).Focused := Value;
end;

procedure TTreeNodeWrapper.SetSelected(Value: Boolean);
begin
  TTreeNode(FObject).Selected := Value;
end;

procedure TTreeNodeWrapper.SetText(const Value: string);
begin
  TTreeNode(FObject).Text := Value;
end;

{ TListItemWrapper }

function TListItemWrapper.GetCaption: String;
begin
  Result := TListItem(FObject).Caption;
end;

function TListItemWrapper.GetFocused: Boolean;
begin
  Result := TListItem(FObject).Focused;
end;

function TListItemWrapper.GetIndent: Integer;
begin
  Result := TListItem(FObject).Indent;
end;

function TListItemWrapper.GetIndex: Integer;
begin
  Result := TListItem(FObject).Index;
end;

function TListItemWrapper.GetLeft: Integer;
begin
  Result := TListItem(FObject).Left;
end;

function TListItemWrapper.GetSelected: Boolean;
begin
  Result := TListItem(FObject).Selected;
end;

function TListItemWrapper.GetSubItems: TStrings;
begin
  Result := TListItem(FObject).SubItems;
end;

function TListItemWrapper.GetTop: Integer;
begin
  Result := TListItem(FObject).Top;
end;

procedure TListItemWrapper.SetCaption(const Value: string);
begin
  TListItem(FObject).Caption := Value;
end;

procedure TListItemWrapper.SetFocused(Value: Boolean);
begin
  TListItem(FObject).Focused := Value;
end;

procedure TListItemWrapper.SetIndent(Value: Integer);
begin
  TListItem(FObject).Indent := Value;
end;

procedure TListItemWrapper.SetSelected(Value: Boolean);
begin
  TListItem(FObject).Selected := Value;
end;

{ TListItemsWrapper }

function TListItemsWrapper.GetCount: Integer;
begin
  Result := TListItems(FObject).Count;
end;

function TListItemsWrapper.GetItem(Index: Integer): TListItem;
begin
  Result := TListItems(FObject).Item[Index];
end;

{ THeaderSectionWrapper }

function THeaderSectionWrapper.GetLeft: Integer;
begin
  Result := THeaderSection(FObject).Left;
end;

function THeaderSectionWrapper.GetRight: Integer;
begin
  Result := THeaderSection(FObject).Right;
end;

{ TCustomGridWrapper }

type
  TCustomGridCracker = class(TCustomGrid);

function TCustomGridWrapper.GetCellRect(ACol, ARow: Integer): TRectClass;
begin
  Result := TRectClass.Create(TCustomGridCracker(FObject).CellRect(ACol, ARow));
end;

{ TAutoRecord }

type
  TAutoRecord = class
  private
    FClass: TClass;
    FObjWrapper: TObjectWrapperClass;
  public
    constructor Create(AClass: TClass; AObjWrapper: TObjectWrapperClass);
    function GetWrapper(AClass: TClass): TObjectWrapperClass;
    function Equal(AClass: TClass): Boolean;
  end;

{ TClassMap }

procedure TClassMap.AddClass(AClass: TClass; AObjWrapper: TObjectWrapperClass);
var
  I: Integer;
begin
  I := 0;
  while I < Count do
  begin
    with TAutoRecord(Items[I]) do
      if AClass.InheritsFrom(FClass) then
        if AClass = FClass then
          raise Exception.CreateFmt(sClassAlreadyInMap, [AClass.ClassName])
        else
          Break;
    Inc(I);      
  end;
  if I < Count then
    inherited Insert(I, TAutoRecord.Create(AClass, AObjWrapper))
  else
    inherited Add(TAutoRecord.Create(AClass, AObjWrapper));
end;

function TClassMap.FindObjectWrapper(AClass: TClass): TObjectWrapperClass;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    with TAutoRecord(Items[I]) do
    begin
      Result := GetWrapper(AClass);
      if Result <> nil then
        Exit;
    end;
  Result := nil;
end;

procedure TClassMap.RemoveClass(AClass: TClass; AObjWrapper: TObjectWrapperClass);
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    with TAutoRecord(Items[I]) do
      if Equal(AClass) and (GetWrapper(AClass) = AObjWrapper) then
        Delete(I);
end;

{ TAutoRecord }

constructor TAutoRecord.Create(AClass: TClass; AObjWrapper: TObjectWrapperClass);
begin
  FClass := AClass;
  FObjWrapper := AObjWrapper;
end;

function TAutoRecord.Equal(AClass: TClass): Boolean;
begin
  Result := AClass = FClass;
end;

function TAutoRecord.GetWrapper(AClass: TClass): TObjectWrapperClass;
begin
  if AClass.InheritsFrom(FClass) then
    Result := FObjWrapper
  else
    Result := nil;
end;

{ TRectClass }

constructor TRectClass.Create(const ARect: TRect);
begin
  FRect := ARect;
end;

function TRectClass.GetBottomRight: TPointClass;
begin
  Result := TPointClass.Create(FRect.TopLeft);
end;

function TRectClass.GetTopLeft: TPointClass;
begin
  Result := TPointClass.Create(FRect.BottomRight);
end;

{ TPointClass }

constructor TPointClass.Create(const APoint: TPoint);
begin
  FPoint := APoint;
end;

{ TScreenWrapper }

function TScreenWrapper.GetForm(Index: Integer): TCustomForm;
begin
  Result := TScreen(FObject).Forms[Index];
end;

function TScreenWrapper.GetFormCount: Integer;
begin
  Result := TScreen(FObject).FormCount;
end;

{ TStringGridWrapper }

function TStringGridWrapper.GetCells(ACol, ARow: Integer): string;
begin
  Result := TStringGrid(FObject).Cells[ACol, ARow];
end;

{ TMenuWrapper }

function TMenuWrapper.FindItem(Index: Integer): TMenuItem;
begin
  Result := TMenu(FObject).FindItem(Index, fkCommand);
end;

function TMenuWrapper.GetHandle: Integer;
begin
  Result := TMenu(FObject).Handle;
end;

{ TRectPointWrapper }

destructor TRectPointWrapper.Destroy;
begin
  FObject.Free;
  inherited;
end;

{ TMenuItemWrapper }

procedure TMenuItemWrapper.Click;
begin
  TMenuItem(FObject).Click;
end;

function TMenuItemWrapper.GetCommand: Integer;
begin
  Result := TMenuItem(FObject).Command;
end;

function TMenuItemWrapper.GetCount: Integer;
begin
  Result := TMenuItem(FObject).Count;
end;

function TMenuItemWrapper.GetHandle: Integer;
begin
  Result := TMenuItem(FObject).Handle;
end;

function TMenuItemWrapper.GetItems(Index: Integer): TMenuItem;
begin
  Result := TMenuItem(FObject).Items[Index];
end;

function TMenuItemWrapper.GetMenuItemIndex: Integer;
begin
  Result := TMenuItem(FObject).MenuIndex;
end;

function TMenuItemWrapper.GetParent: TMenuItem;
begin
  Result := TMenuItem(FObject).Parent;
end;

{ TCheckListBoxWrapper }

function TCheckListBoxWrapper.GetChecked(Index: Integer): Boolean;
begin
  Result := TCheckListBox(FObject).Checked[Index];
end;

function TCheckListBoxWrapper.GetItemEnabled(Index: Integer): Boolean;
begin
  Result := TCheckListBox(FObject).ItemEnabled[Index];
end;

function TCheckListBoxWrapper.GetHeader(Index: Integer): Boolean;
begin
  Result := TCheckListBox(FObject).Header[Index];
end;

function TCheckListBoxWrapper.GetState(Index: Integer): TCheckBoxState;
begin
  Result := TCheckListBox(FObject).State[Index]
end;

procedure TCheckListBoxWrapper.SetChecked(Index: Integer; Value: Boolean);
begin
  TCheckListBox(FObject).Checked[Index] := Value;
end;

procedure TCheckListBoxWrapper.SetItemEnabled(Index: Integer; Value: Boolean);
begin
  TCheckListBox(FObject).ItemEnabled[Index] := Value;
end;

procedure TCheckListBoxWrapper.SetHeader(Index: Integer; Value: Boolean);
begin
  TCheckListBox(FObject).Header[Index] := Value;
end;

procedure TCheckListBoxWrapper.SetState(Index: Integer; Value: TCheckBoxState);
begin
  TCheckListBox(FObject).State[Index] := Value;
end;

{ TTabSetWrapper }

function TTabSetWrapper.GetItemRect(Item: Integer): TRectClass;
begin
  Result := TRectClass.Create(TTabSet(FObject).ItemRect(Item));
end;

{ TStringsWrapper }

function TStringsWrapper.Add(const Item: string): Integer;
begin
  Result := TStrings(FObject).Add(Item);
end;

procedure TStringsWrapper.Clear;
begin
  TStrings(FObject).Clear;
end;

procedure TStringsWrapper.Delete(Index: Integer);
begin
  TStrings(FObject).Delete(Index);
end;

function TStringsWrapper.GetCount: Integer;
begin
  Result := TStrings(FObject).Count;
end;

function TStringsWrapper.GetObjects(Index: Integer): TObject;
begin
  Result := TStrings(FObject).Objects[Index];
end;

function TStringsWrapper.GetStrings(Index: Integer): string;
begin
  Result := TStrings(FObject).Strings[Index];
end;

function TStringsWrapper.IndexOf(const Item: string): Integer;
begin
  Result := TStrings(FObject).IndexOf(Item);
end;

{ TPictureWrapper }

function TPictureWrapper.GetBitmap: TBitmap;
begin
  Result := TPicture(FObject).Bitmap;
end;

function TPictureWrapper.GetGraphic: TGraphic;
begin
  Result := TPicture(FObject).Graphic;
end;

function TPictureWrapper.GetHeight: Integer;
begin
  Result := TPicture(FObject).Height;
end;

function TPictureWrapper.GetIcon: TIcon;
begin
  Result := TPicture(FObject).Icon;
end;

function TPictureWrapper.GetWidth: Integer;
begin
  Result := TPicture(FObject).Width;
end;

{ TGraphicWrapper }

function TGraphicWrapper.GetHeight: Integer;
begin
  Result := TGraphic(FObject).Height;
end;

function TGraphicWrapper.GetModified: Boolean;
begin
  Result := TGraphic(FObject).Modified;
end;

function TGraphicWrapper.GetTransParent: Boolean;
begin
  Result := TGraphic(FObject).Transparent;
end;

function TGraphicWrapper.GetWidth: Integer;
begin
  Result := TGraphic(FObject).Width;
end;

{ TBitmapWrapper }

function TBitmapWrapper.GetHandleType: TBitmapHandleType;
begin
  Result := TBitmap(FObject).HandleType;
end;

function TBitmapWrapper.GetHeight: Integer;
begin
  Result := TBitmap(FObject).Height;
end;

function TBitmapWrapper.GetMonochrome: Boolean;
begin
  Result := TBitmap(FObject).Monochrome;
end;

function TBitmapWrapper.GetTransparentColor: Integer;
begin
  Result := TBitmap(FObject).TransparentColor;
end;

function TBitmapWrapper.GetWidth: Integer;
begin
  Result := TBitmap(FObject).Width;
end;

{ TMemoWrapper }

function TMemoWrapper.GetLines: TStrings;
begin
  Result := TCustomMemo(FObject).Lines;
end;

initialization
  with ClassMap do
  begin
    AddClass(TObject, TObjectWrapper);
    AddClass(TApplication, TApplicationWrapper);
    AddClass(TComponent, TComponentWrapper);
    AddClass(TControl, TControlWrapper);
    AddClass(TWinControl, TWinControlWrapper);
    AddClass(TRectClass, TRectPointWrapper);
    AddClass(TPointClass, TRectPointWrapper);
    AddClass(TScreen, TScreenWrapper);
    AddClass(TCollectionItem, TCollectionItemWrapper);
    AddClass(TCollection, TCollectionWrapper);
    AddClass(TTabSheet, TTabSheetWrapper);
    AddClass(TCustomTabControl, TCustomTabControlWrapper);
    AddClass(TCustomGrid, TCustomGridWrapper);
    AddClass(TStringGrid, TStringGridWrapper);
    AddClass(TStrings, TStringsWrapper);
    AddClass(TCustomTreeView, TCustomTreeViewWrapper);
    AddClass(TTreeNodes, TTreeNodesWrapper);
    AddClass(TTreeNode, TTreeNodeWrapper);
    AddClass(TCustomListView, TCustomListViewWrapper);
    AddClass(TListItems, TListItemsWrapper);
    AddClass(TListItem, TListItemWrapper);
    AddClass(THeaderSection, THeaderSectionWrapper);
    AddClass(TStatusPanel, TStatusPanelWrapper);
    AddClass(TMenu, TMenuWrapper);
    AddClass(TMenuItem, TMenuItemWrapper);
    AddClass(TCustomListBox, TCustomListBoxWrapper);
    AddClass(TCheckListBox, TCheckListBoxWrapper);
    AddClass(TTabSet, TTabSetWrapper);
    AddClass(TPicture, TPictureWrapper);
    AddClass(TGraphic, TGraphicWrapper);
    AddClass(TBitmap, TBitmapWrapper);
    AddClass(TCustomMemo, TMemoWrapper);
  end;
end.
