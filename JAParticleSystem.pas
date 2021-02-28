unit JAParticleSystem;
{$mode objfpc}{$H+}

interface

uses
   JTypes,
   JATypes, JASpatial;

type
   TJAParticle = record
      Position : TVec2;
      Velocity : TVec2;
      Rotation : Float32;
      RotationVelocity : Float32;
      Colour : TJColour;
      Age : Float32;
      Death : Float32;
   end;
   PJAParticle = ^TJAParticle;

   TJAParticleSystem = record
      Spatial : TJASpatial;
      Particles : array of TJAParticle;
      ParticlesCount : UInt32;
   end;
   PJAParticleSystem = ^TJAParticleSystem;

function JAParticleSystemCreate() : PJAParticleSystem;
function JAParticleSystemDestroy(AParticleSystem : PJAParticleSystem) : boolean;

implementation

function JAParticleSystemCreate : PJAParticleSystem;
begin
   Result := JAMemGet(SizeOf(TJAParticleSystem);
   Result^.Spatial := JASpatialDefault;
   SetLength(Result^.Particles,0);
   Result^.ParticlesCount := 0;
end;

function JAParticleSystemDestroy(AParticleSystem : PJAParticleSystem) : boolean;
begin
   SetLength(Result^.Particles,0);
   JAMemFree(AParticleSystem);
end;

end.

