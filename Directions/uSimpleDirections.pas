unit uSimpleDirections;

interface

uses
   SysUtils, Classes;

type
   TSimpleStep = class(TObject)
   private
      fLocation: String;
      fDistanceHTML: String;
      fDescriptionHTML: String;
      fUniqueStepID: Integer;
   public
      property Location: String read FLocation write FLocation;
      property DescriptionHTML: String read FDescriptionHTML write FDescriptionHTML;
      property DistanceHTML: String read FDistanceHTML write FDistanceHTML;

      property UniqueStepID: Integer read fUniqueStepID write fUniqueStepID;
   end;

   TSimpleWaypoint = class(TObject)
   private
      fSteps: TList;

      fLocation, fAddress, fRouteDistanceHTML, fRouteDurationHTML: String;

      function GetStep(Index: Integer): TSimpleStep;
   public
      constructor Create(const aLocation, aAddress, aRouteDistanceHTML, aRouteDurationHTML: String);
      destructor Destroy; override;

      procedure Clear;

      procedure AddStep(const aLocation, aStepDescriptionHTML, aStepDistanceHTML: String; aUniqueStepID: Integer);

      function Count: Integer;

      property Steps[Index: Integer]: TSimpleStep read GetStep;

      property Location: String read fLocation;
      property Address: String read fAddress;
      property RouteDistanceHTML: String read fRouteDistanceHTML;
      property RouteDurationHTML: String read fRouteDurationHTML;
   end;

   TSimpleDirections = class(TObject)
   private
      fCurrentWaypoint: Integer;
      fWaypoints: TList;
      fUniqueStepID: Integer;

      function GetWaypoint(Index: Integer): TSimpleWaypoint;
   public
      constructor Create;
      destructor Destroy; override;

      procedure Clear;

      procedure AddWaypoint(const aLocation, aAddress, aRouteDistanceHTML, aRouteDurationHTML: String);
      procedure AddStep(const aLocation, aStepDescriptionHTML, aStepDistanceHTML: String);

      function Count: Integer;

      function FindStep(aUniqueStepID: Integer): TSimpleStep;

      property Waypoints[Index: Integer]: TSimpleWaypoint read GetWaypoint;
   end;


implementation

{ TSimpleDirections }

constructor TSimpleDirections.Create;
begin
   fWaypoints := TList.Create;
end;

destructor TSimpleDirections.Destroy;
begin
   Clear;

   fWaypoints.Free;
   inherited;
end;

function TSimpleDirections.FindStep(aUniqueStepID: Integer): TSimpleStep;
var
   i, j: Integer;
   wp: TSimpleWaypoint;
   s: TSimpleStep;
begin
   Result := nil;

   for i := 0 to Count - 1 do
   begin
      wp := Waypoints[i];
      for j := 0 to wp.Count - 1 do
      begin
         s := wp.Steps[j];

         if s.UniqueStepID = aUniqueStepID then
         begin
            Result := s;
            break;
         end;
      end;
   end;
end;

function TSimpleDirections.GetWaypoint(Index: Integer): TSimpleWaypoint;
begin
   Result := TSimpleWaypoint(fWaypoints[Index]);
end;

procedure TSimpleDirections.Clear;
var
   wp: TSimpleWaypoint;
begin
   while fWaypoints.Count > 0 do
   begin
      wp := TSimpleWaypoint(fWaypoints[0]);
      wp.Free;
      fWaypoints.Delete(0);
   end;

   fUniqueStepID := 0;
end;

function TSimpleDirections.Count: Integer;
begin
   Result := fWaypoints.Count;
end;

procedure TSimpleDirections.AddWaypoint(const aLocation, aAddress, aRouteDistanceHTML, aRouteDurationHTML: String);
var
   wp: TSimpleWaypoint;
begin
   wp := TSimpleWaypoint.Create(aLocation, aAddress, aRouteDistanceHTML, aRouteDurationHTML);
   fWaypoints.Add(wp);
   fCurrentWaypoint := fWayPoints.Count - 1;
end;

procedure TSimpleDirections.AddStep(const aLocation, aStepDescriptionHTML, aStepDistanceHTML: String);
begin
   Inc(fUniqueStepID);
   TSimpleWaypoint(fWaypoints[fCurrentWaypoint]).AddStep(aLocation, aStepDescriptionHTML, aStepDistanceHTML, fUniqueStepID);
end;

{ TSimpleWaypoint }

constructor TSimpleWaypoint.Create(const aLocation, aAddress, aRouteDistanceHTML, aRouteDurationHTML: String);
begin
   fSteps := TList.Create;

   fLocation := aLocation;
   fAddress := aAddress;
   fRouteDistanceHTML := aRouteDistanceHTML;
   fRouteDurationHTML := aRouteDurationHTML;
end;

destructor TSimpleWaypoint.Destroy;
begin
   Clear;

   fSteps.Free;

   inherited;
end;

function TSimpleWaypoint.GetStep(Index: Integer): TSimpleStep;
begin
   Result := TSimpleStep(fSteps[Index]);
end;

procedure TSimpleWaypoint.Clear;
var
   s: TSimpleStep;
begin
   while fSteps.Count > 0 do
   begin
      s := TSimpleStep(fSteps[0]);
      s.Free;
      fSteps.Delete(0);
   end;
end;

function TSimpleWaypoint.Count: Integer;
begin
   Result := fSteps.Count;
end;

procedure TSimpleWaypoint.AddStep(const aLocation, aStepDescriptionHTML, aStepDistanceHTML: String; aUniqueStepID: Integer);
var
   s: TSimpleStep;
begin
   s := TSimpleStep.Create;

   s.Location := aLocation;
   s.DescriptionHTML := aStepDescriptionHTML;
   s.DistanceHTML := aStepDistanceHTML;
   s.UniqueStepID := aUniqueStepID;

   fSteps.Add(s);
end;

end.
