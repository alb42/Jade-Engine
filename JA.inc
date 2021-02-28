{--------------------------------------------------------------------- Compiler}

{$DEFINE JA_INLINE}
{$IFDEF JA_INLINE} {$INLINE ON} {$ENDIF}
{$IFNDEF JA_INLINE} {$INLINE OFF} {$ENDIF}


{-------------------------------------------------------------------- Framework}

{.$DEFINE JA_ENABLE_SHADOW} {Enable/Disable Shadow Code}
{$DEFINE JA_ENABLE_CURSOR} {Enable/Disable Cursor Code}
{$DEFINE JA_ENABLE_POLYGON} {Enable/Disable Polygon Code}

{------------------------------------------------------------------- SceneGraph}

{$DEFINE JA_SCENE_MAT3} {Use 3x3 Matrix SceneGraph Code}
{.$DEFINE JA_SCENE_MAT2} {Use 2x2 Matrix SceneGraph Code}
{$DEFINE JA_SCENE_VEC2} {Use Vec PosRot SceneGraph Code}

{------------------------------------------------------------------------ Debug}

{$DEFINE JA_DEBUG}
{$IFDEF JA_DEBUG}
   {.$DEFINE JA_DEBUG_HEAPTRC}
   {.$DEFINE JA_DEBUG_LOG}
{$ENDIF}

{----------------------------------------------------------- Platform Specifics}

{$IFDEF AMIGA68K} {Classic Amiga}

{$ENDIF}

{$IFDEF AMIGAOS4} {AmigaOS4}

{$ENDIF}

{$IFDEF AMIGA} {Classic Amiga, AmigaOS4}

{$ENDIF}

{$IFDEF HASAMIGA} {Classic Amiga, AmigaOS4, AROS, MorphOS}

{$ENDIF}
