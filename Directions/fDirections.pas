unit fDirections;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, SHDocVw, MSHTML,
  Automation, uWBGoogleMaps, uSimpleDirections, ExtCtrls;

const
   WM_ONSHOWCALLBACK = WM_USER + 565;

type
  TfrmDirections = class(TForm)
    WebBrowser1: TWebBrowser;
    lblFrom: TLabel;
    eFrom: TEdit;
    lblTo: TLabel;
    eTo: TEdit;
    btnDirections: TButton;
    ListBox1: TListBox;
    eTo2: TEdit;
    lblTo2: TLabel;
    lblDirections: TLabel;
    pnlRight: TPanel;
    Splitter1: TSplitter;
    procedure FormResize(Sender: TObject);
    procedure btnDirectionsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    { Private declarations }
    done, fAllowResizeHandler, fCreatedGDirections: Boolean;
    fWBGoogleMaps: TWBGoogleMaps;
    fSimpleDirections: TSimpleDirections;

    function WBOnGetExternal(out ppDispatch: IDispatch): HResult; stdcall;
  public
    { Public declarations }
    procedure OnShowCallback(var aMsg: TMessage); message WM_ONSHOWCALLBACK;
  end;

  TExtJavaScript = class(TObjectWrapper)
  published
    procedure NewDirections;
    procedure AddWaypoint(const aLocation, aAddress, aRouteDistanceHTML, aRouteDurationHTML: String);
    procedure AddStep(const aLocation, aStepDescriptionHTML, aStepDistanceHTML: String);

    procedure CopyRight(const aValue: String);
  end;


var
  frmDirections: TfrmDirections;

implementation

{$R *.dfm}

procedure TfrmDirections.FormCreate(Sender: TObject);
begin
   fWBGoogleMaps := TWBGoogleMaps.Create(WebBrowser1);
   fWBGoogleMaps.OnGetExternal := WBOnGetExternal;

   fSimpleDirections := TSimpleDirections.Create;
end;

procedure TfrmDirections.FormDestroy(Sender: TObject);
begin
   fSimpleDirections.Free;
   fWBGoogleMaps.Free;
end;

procedure TfrmDirections.FormShow(Sender: TObject);
begin
   if not done then
   begin
      // I want to have the application show its window, then start loading the webpage.
      PostMessage(Handle, WM_ONSHOWCALLBACK, 0, 0);

      done := true;
   end;
end;

procedure TfrmDirections.ListBox1Click(Sender: TObject);
var
   id: Integer;
   step: TSimpleStep;
   waypoint: TSimpleWaypoint;
begin
   if (Sender as TListbox).ItemIndex > -1 then
   begin
      id := Integer(TListbox(Sender).Items.Objects[TListbox(Sender).ItemIndex]);

      if id > 0 then
      begin
         step := fSimpleDirections.FindStep(id);
         if Assigned(step) then
         begin
            fWBGoogleMaps.ExecJS(
               'map.showMapBlowup(new GLatLng(' + step.Location + '));'
            );
         end;
      end
      // id = 0 is for the last waypoint, which doesn't have any steps
      else if (id = 0) and (fSimpleDirections.Count > 0) then
      begin
         waypoint := fSimpleDirections.Waypoints[fSimpleDirections.Count - 1];
         if Assigned(waypoint) then
         begin
            fWBGoogleMaps.ExecJS(
               'map.showMapBlowup(new GLatLng(' + waypoint.Location + '));'
            );
         end;
      end;
   end;
end;

procedure TfrmDirections.OnShowCallback(var aMsg: TMessage);
begin
   fWBGoogleMaps.LoadDefaultGoogleMapsDocument;
   fAllowResizeHandler := true;
   FormResize(nil);
end;

procedure TfrmDirections.FormResize(Sender: TObject);
begin
   if fAllowResizeHandler then
   begin
      if fWBGoogleMaps.LoadedGoogleMaps then
      begin
         while WebBrowser1.ReadyState < READYSTATE_COMPLETE do
            Forms.Application.ProcessMessages;

         fWBGoogleMaps.ExecJS(
            'if (document) { ' +
            '  if (document.body) { ' +
            '    var m = document.getElementById("map"); ' +
            '    if (typeof(m) != "undefined") { ' +
            '      m.style.height = ' + IntToStr(WebBrowser1.ClientHeight) + '; ' +
            '    } ' +
            '  } ' +
            '} '
         );
      end;
   end;
end;

procedure TfrmDirections.btnDirectionsClick(Sender: TObject);
var
   sFrom, sTo, sTo2: String;
begin
   if not fCreatedGDirections then
   begin
      fWBGoogleMaps.ExecJS('var dirn = new GDirections(map);');
      fWBGoogleMaps.ExecJS(
         'function onGDirectionsLoad() {' +
         '  if (dirn.getNumRoutes() > 0) {                                                                                    ' +
         '    external.NewDirections();                                                                                       ' +
         '    /* set option preserveViewport because it does not zoom correctly in the TWebBrowser */                         ' +
         '    map.setCenter(dirn.getRoute(0).getStep(0).getLatLng());                                                         ' +
         '  }                                                                                                                 ' +
         '                                                                                                                    ' +
         '  var route = "";                                                                                                   ' +
         '  var geocode = "";                                                                                                 ' +
         '  for (var i=0; i < dirn.getNumRoutes(); ++i) {                                                                     ' +
         '    route = dirn.getRoute(i);                                                                                       ' +
         '    geocode = route.getStartGeocode();                                                                              ' +
         '    var point = route.getStep(0).getLatLng();                                                                       ' +
         '                                                                                                                    ' +
         '    external.AddWaypoint(point.toUrlValue(6), geocode.address, route.getDistance().html, route.getDuration().html); ' +
         '                                                                                                                    ' +
         '    for (var j=0; j < route.getNumSteps(); ++j) {                                                                   ' +
         '      var step = route.getStep(j);                                                                                  ' +
         '                                                                                                                    ' +
         '      var latlng = "";                                                                                              ' +
         '      var descr  = "";                                                                                              ' +
         '      var dist   = "";                                                                                              ' +
         '                                                                                                                    ' +
         '      if (step.getLatLng())                                                                                         ' +
         '        latlng = step.getLatLng().toUrlValue(6);                                                                    ' +
         '      if (step.getDescriptionHtml())                                                                                ' +
         '        descr  = step.getDescriptionHtml();                                                                         ' +
         '      if (step.getDistance())                                                                                       ' +
         '        dist   = step.getDistance().html;                                                                           ' +
         '                                                                                                                    ' +
         '      external.AddStep(latlng, descr, dist);                                                                        ' +
         '    }                                                                                                               ' +
         '  }                                                                                                                 ' +
         '                                                                                                                    ' +
         '  geocode = route.getEndGeocode();                                                                                  ' +
         '  external.AddWaypoint(route.getEndLatLng().toUrlValue(6), geocode.address, "", "");                                ' +
         '                                                                                                                    ' +
         '  external.CopyRight(dirn.getCopyrightsHtml());                                                                     ' +
         '}'
      );
      fWBGoogleMaps.ExecJS('GEvent.addListener(dirn, "load", onGDirectionsLoad);');
   end;

   sFrom := Trim(StringReplace(eFrom.Text, '"', '\"', [rfReplaceAll]));
   sTo   := Trim(StringReplace(eTo.Text,   '"', '\"', [rfReplaceAll]));
   // optional third waypoint
   sTo2  := Trim(StringReplace(eTo2.Text,  '"', '\"', [rfReplaceAll]));
   if sTo2 <> '' then
      sTo2 := ' to: ' + sTo2;

   fWBGoogleMaps.ExecJS('dirn.load("from: ' + sFrom + ' to: ' + sTo + sTo2 + '", {getSteps:true,preserveViewport:true});');
end;

function TfrmDirections.WBOnGetExternal(out ppDispatch: IDispatch): HResult;
var
   W: TExtJavaScript;
begin
   ///   This allows javascript on the webpage (or injected from Delphi)
   ///   to call Delphi functions using "external.procedure()"

   W := TExtJavaScript.Connect(Forms.Application);
   ppDispatch := TAutoObjectDispatch.Create(W) as IDispatch;
   Result := S_OK;
end;

{ TExtJavaScript }

procedure TExtJavaScript.NewDirections;
begin
   frmDirections.Listbox1.Clear;
   frmDirections.fSimpleDirections.Clear;
end;

procedure TExtJavaScript.AddStep(const aLocation, aStepDescriptionHTML, aStepDistanceHTML: String);
begin
   frmDirections.fSimpleDirections.AddStep(aLocation, aStepDescriptionHTML, aStepDistanceHTML);
end;

procedure TExtJavaScript.AddWaypoint(const aLocation, aAddress, aRouteDistanceHTML, aRouteDurationHTML: String);
begin
   frmDirections.fSimpleDirections.AddWaypoint(aLocation, aAddress, aRouteDistanceHTML, aRouteDurationHTML);
end;

function RemoveHTML(const s: String): String;
var
   i: Integer;
   inBraces: Boolean;
begin
   Result := '';
   i := 1;

   inBraces := false;
   while i <= Length(s) do
   begin
      if s[i] = '<' then
         inBraces := true
      else if s[i] = '>' then
         inBraces := false
      else if not inBraces then
      begin
         if s[i] = '&' then
         begin
            if SameText(Copy(s, i, 6), '&nbsp;') then
            begin
               Result := Result + ' ';
               Inc(i, 5);
            end;
         end
         else
            Result := Result + s[i];
      end;

      Inc(i);
   end;
end;

procedure TExtJavaScript.CopyRight(const aValue: String);
var
   i, j: Integer;
   waypointLetter: Char;
   wp: TSimpleWaypoint;
   s: TSimpleStep;
   UniqueStepID: Integer;
   routeDistance: String;
begin
   waypointLetter := 'A';

   for i := 0 to frmDirections.fSimpleDirections.Count - 1 do
   begin
      wp := frmDirections.fSimpleDirections.Waypoints[i];

      if wp.Count > 0 then
         UniqueStepID := wp.Steps[0].UniqueStepID
      else // UniqueStepID = 0 is for the last waypoint, which doesn't have any steps
         UniqueStepID := 0;

      if wp.RouteDistanceHTML = '' then
         routeDistance := ''
      else
         routeDistance := ' [' + wp.RouteDistanceHTML + ']';

      frmDirections.ListBox1.AddItem(
         waypointLetter + ': ' + RemoveHTML(wp.Address + routeDistance),
         Pointer(UniqueStepID)
      );

      for j := 0 to wp.Count - 1 do
      begin
         s := wp.Steps[j];

         frmDirections.ListBox1.AddItem(
            '  ' + IntToStr(j+1) + ': ' + RemoveHTML(s.DescriptionHTML),
            Pointer(s.UniqueStepID) // put a unique ID in the Item's Object for the callback.
         );
      end;

      Inc(waypointLetter);
   end;

   frmDirections.ListBox1.AddItem(
      ' ** ' + StringReplace(aValue, '&#169;', '©', [rfReplaceAll]) + ' ** ',
      Pointer(-2)
   );
end;

end.
