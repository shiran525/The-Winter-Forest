// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Winter Environment/Standard Snow Cutout Two Sided"
{
	Properties
	{
		_BaseColor("Base Color", 2D) = "white" {}
		[Toggle(_USEMASK_ON)] _UseMask("Use Mask", Float) = 0
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Normal("Normal", 2D) = "bump" {}
		_AmbientOcclusion("Ambient Occlusion", 2D) = "white" {}
		_Smoothness("Smoothness", 2D) = "gray" {}
		_Metallic("Metallic", 2D) = "white" {}
		_SmoothnessStrength("Smoothness Strength", Range( 0 , 1)) = 0
		[Toggle(_SMOOTHNESSINMETALLIC_ON)] _SmoothnessinMetallic("Smoothness in Metallic?", Float) = 0
		[Toggle(_USEMETALLIC_ON)] _UseMetallic("Use Metallic", Float) = 0
		_SnowColor("Snow Color", Color) = (0.8000001,0.8431373,0.8784314,0)
		[Toggle(_USESNOWTEXTURE_ON)] _UseSnowTexture("Use Snow Texture", Float) = 0
		_SnowAlbedo("Snow Albedo", 2D) = "white" {}
		_SnowNormal("Snow Normal", 2D) = "white" {}
		_SnowUVScale("Snow UV Scale", Range( 0 , 10)) = 0.2
		_SnowAccumulation("Snow Accumulation", Range( 0 , 5)) = 0
		_SnowSharpness("Snow Sharpness", Range( 1 , 10)) = 1
		_ObjectNormalIntensity("Object Normal Intensity", Range( 0 , 1)) = 0.5
		_SnowNormalIntensity("Snow Normal Intensity", Range( 0 , 3)) = 5
		_SnowAOCancellation("Snow AO Cancellation", Range( 0 , 1)) = 1
		[Toggle(_USEDETAILMAP_ON)] _UseDetailMap("Use Detail Map", Float) = 0
		_DetailAlbedo("DetailAlbedo", 2D) = "white" {}
		_DetailNormal("DetailNormal", 2D) = "white" {}
		_DetailNormalScale("Detail Normal Scale", Range( 0 , 2)) = 1
		_DetailTiling("Detail Tiling", Range( 0.1 , 5)) = 1
		_DetailAlbedoStrength("Detail Albedo Strength", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" }
		Cull Off
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature _USEDETAILMAP_ON
		#pragma shader_feature _USESNOWTEXTURE_ON
		#pragma shader_feature _USEMETALLIC_ON
		#pragma shader_feature _SMOOTHNESSINMETALLIC_ON
		#pragma shader_feature _USEMASK_ON
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) fixed3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _DetailNormal;
		uniform float _DetailTiling;
		uniform float _DetailNormalScale;
		uniform float _ObjectNormalIntensity;
		uniform sampler2D _SnowNormal;
		uniform float _SnowUVScale;
		uniform float _SnowNormalIntensity;
		uniform float _SnowAccumulation;
		uniform float _SnowSharpness;
		uniform sampler2D _BaseColor;
		uniform float4 _BaseColor_ST;
		uniform sampler2D _DetailAlbedo;
		uniform float _DetailAlbedoStrength;
		uniform float4 _SnowColor;
		uniform sampler2D _SnowAlbedo;
		uniform sampler2D _Metallic;
		uniform float4 _Metallic_ST;
		uniform sampler2D _Smoothness;
		uniform float4 _Smoothness_ST;
		uniform float _SmoothnessStrength;
		uniform sampler2D _AmbientOcclusion;
		uniform float4 _AmbientOcclusion_ST;
		uniform float _SnowAOCancellation;
		uniform float _Cutoff = 0.5;


		inline float3 TriplanarSamplingSNF( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float tilling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= projNormal.x + projNormal.y + projNormal.z;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = ( tex2D( topTexMap, tilling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
			yNorm = ( tex2D( topTexMap, tilling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			zNorm = ( tex2D( topTexMap, tilling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
			xNorm.xyz = half3( UnpackScaleNormal( xNorm, normalScale.y ).xy * float2( nsign.x, 1.0 ) + worldNormal.zy, worldNormal.x ).zyx;
			yNorm.xyz = half3( UnpackScaleNormal( yNorm, normalScale.x ).xy * float2( nsign.y, 1.0 ) + worldNormal.xz, worldNormal.y ).xzy;
			zNorm.xyz = half3( UnpackScaleNormal( zNorm, normalScale.y ).xy * float2( -nsign.z, 1.0 ) + worldNormal.xy, worldNormal.z ).xyz;
			return normalize( xNorm.xyz * projNormal.x + yNorm.xyz * projNormal.y + zNorm.xyz * projNormal.z );
		}


		inline float4 TriplanarSamplingSF( sampler2D topTexMap, float3 worldPos, float3 worldNormal, float falloff, float tilling, float3 normalScale, float3 index )
		{
			float3 projNormal = ( pow( abs( worldNormal ), falloff ) );
			projNormal /= projNormal.x + projNormal.y + projNormal.z;
			float3 nsign = sign( worldNormal );
			half4 xNorm; half4 yNorm; half4 zNorm;
			xNorm = ( tex2D( topTexMap, tilling * worldPos.zy * float2( nsign.x, 1.0 ) ) );
			yNorm = ( tex2D( topTexMap, tilling * worldPos.xz * float2( nsign.y, 1.0 ) ) );
			zNorm = ( tex2D( topTexMap, tilling * worldPos.xy * float2( -nsign.z, 1.0 ) ) );
			return xNorm * projNormal.x + yNorm * projNormal.y + zNorm * projNormal.z;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			float3 tex2DNode11 = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_worldTangent = WorldNormalVector( i, float3( 1, 0, 0 ) );
			float3 ase_worldBitangent = WorldNormalVector( i, float3( 0, 1, 0 ) );
			float3x3 ase_worldToTangent = float3x3( ase_worldTangent, ase_worldBitangent, ase_worldNormal );
			float3 triplanar63 = TriplanarSamplingSNF( _DetailNormal, ase_worldPos, ase_worldNormal, 10.0, _DetailTiling, _DetailNormalScale, 0 );
			float3 tanTriplanarNormal63 = mul( ase_worldToTangent, triplanar63 );
			#ifdef _USEDETAILMAP_ON
				float3 staticSwitch67 = BlendNormals( tex2DNode11 , tanTriplanarNormal63 );
			#else
				float3 staticSwitch67 = tex2DNode11;
			#endif
			float4 _Color0 = float4(1,1,1,0);
			float4 appendResult54 = (float4(( _Color0.r * _ObjectNormalIntensity ) , ( _Color0.g * _ObjectNormalIntensity ) , _Color0.b , 0.0));
			float4 temp_output_48_0 = ( float4( tex2DNode11 , 0.0 ) * appendResult54 );
			float3 triplanar81 = TriplanarSamplingSNF( _SnowNormal, ase_worldPos, ase_worldNormal, 1.0, _SnowUVScale, _SnowNormalIntensity, 0 );
			float3 tanTriplanarNormal81 = mul( ase_worldToTangent, triplanar81 );
			#ifdef _USESNOWTEXTURE_ON
				float4 staticSwitch86 = float4( BlendNormals( tanTriplanarNormal81 , temp_output_48_0.xyz ) , 0.0 );
			#else
				float4 staticSwitch86 = temp_output_48_0;
			#endif
			float _snowMask96 = saturate( pow( ( saturate( WorldNormalVector( i , staticSwitch67 ).y ) * _SnowAccumulation ) , _SnowSharpness ) );
			float4 lerpResult42 = lerp( float4( staticSwitch67 , 0.0 ) , staticSwitch86 , _snowMask96);
			o.Normal = lerpResult42.xyz;
			float2 uv_BaseColor = i.uv_texcoord * _BaseColor_ST.xy + _BaseColor_ST.zw;
			float4 tex2DNode7 = tex2D( _BaseColor, uv_BaseColor );
			float4 triplanar62 = TriplanarSamplingSF( _DetailAlbedo, ase_worldPos, ase_worldNormal, 10.0, _DetailTiling, 1.0, 0 );
			float4 blendOpSrc65 = triplanar62;
			float4 blendOpDest65 = tex2DNode7;
			#ifdef _USEDETAILMAP_ON
				float4 staticSwitch66 = ( saturate( (( blendOpDest65 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest65 - 0.5 ) ) * ( 1.0 - blendOpSrc65 ) ) : ( 2.0 * blendOpDest65 * blendOpSrc65 ) ) ));
			#else
				float4 staticSwitch66 = tex2DNode7;
			#endif
			float4 lerpResult75 = lerp( tex2DNode7 , staticSwitch66 , _DetailAlbedoStrength);
			float4 triplanar80 = TriplanarSamplingSF( _SnowAlbedo, ase_worldPos, ase_worldNormal, 1.0, _SnowUVScale, 1.0, 0 );
			#ifdef _USESNOWTEXTURE_ON
				float4 staticSwitch84 = triplanar80;
			#else
				float4 staticSwitch84 = _SnowColor;
			#endif
			float4 lerpResult13 = lerp( lerpResult75 , staticSwitch84 , _snowMask96);
			o.Albedo = lerpResult13.rgb;
			float2 uv_Metallic = i.uv_texcoord * _Metallic_ST.xy + _Metallic_ST.zw;
			float4 tex2DNode8 = tex2D( _Metallic, uv_Metallic );
			#ifdef _USEMETALLIC_ON
				float staticSwitch93 = tex2DNode8.r;
			#else
				float staticSwitch93 = 0.0;
			#endif
			o.Metallic = staticSwitch93;
			float2 uv_Smoothness = i.uv_texcoord * _Smoothness_ST.xy + _Smoothness_ST.zw;
			#ifdef _SMOOTHNESSINMETALLIC_ON
				float staticSwitch90 = tex2DNode8.a;
			#else
				float staticSwitch90 = tex2D( _Smoothness, uv_Smoothness ).r;
			#endif
			float lerpResult87 = lerp( ( staticSwitch90 * _SmoothnessStrength ) , triplanar80.w , _snowMask96);
			o.Smoothness = lerpResult87;
			float2 uv_AmbientOcclusion = i.uv_texcoord * _AmbientOcclusion_ST.xy + _AmbientOcclusion_ST.zw;
			float4 tex2DNode12 = tex2D( _AmbientOcclusion, uv_AmbientOcclusion );
			float4 temp_cast_9 = (1.0).xxxx;
			float4 lerpResult57 = lerp( tex2DNode12 , temp_cast_9 , _SnowAOCancellation);
			float4 lerpResult46 = lerp( tex2DNode12 , lerpResult57 , _snowMask96);
			o.Occlusion = lerpResult46.r;
			o.Alpha = 1;
			#ifdef _USEMASK_ON
				float staticSwitch40 = tex2DNode7.a;
			#else
				float staticSwitch40 = 1.0;
			#endif
			clip( staticSwitch40 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal( v.normal );
				fixed3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				fixed tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				fixed3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			fixed4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				fixed3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15301
296;229;1666;962;1768.743;-260.9092;1.336973;True;True
Node;AmplifyShaderEditor.RangedFloatNode;68;-3146.331,1947.954;Float;False;Property;_DetailTiling;Detail Tiling;24;0;Create;True;0;0;False;0;1;1;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;69;-3143.874,2058.4;Float;False;Property;_DetailNormalScale;Detail Normal Scale;23;0;Create;True;0;0;False;0;1;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-3067.417,2218.606;Float;False;Constant;_Float2;Float 2;25;0;Create;True;0;0;False;0;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-3166.477,-1769.946;Float;True;Property;_Normal;Normal;3;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TriplanarNode;63;-2734.53,2131.336;Float;True;Spherical;World;True;DetailNormal;_DetailNormal;white;22;None;Mid Texture 1;_MidTexture1;white;-1;None;Bot Texture 1;_BotTexture1;white;-1;None;Detail Normal;False;9;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;8;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;2;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;64;-2255.324,396.7232;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;67;-1993.989,332.645;Float;False;Property;_UseDetailMap;Use Detail Map;20;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;28;-1639.594,498.2228;Float;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;53;-3941.426,460.7738;Float;False;Constant;_Color0;Color 0;6;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;45;-3980.447,656.5804;Float;False;Property;_ObjectNormalIntensity;Object Normal Intensity;17;0;Create;True;0;0;False;0;0.5;0.273;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;105;-1415.273,550.2412;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;18;-1263.028,764.3429;Float;False;Property;_SnowAccumulation;Snow Accumulation;15;0;Create;True;0;0;False;0;0;1.26;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-3649.126,526.1452;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;-3648.102,414.3944;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-1093.174,573.1058;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;-956.4977,765.0942;Float;False;Property;_SnowSharpness;Snow Sharpness;16;0;Create;True;0;0;False;0;1;4.69;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;54;-3411.427,493.7544;Float;True;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TriplanarNode;62;-2743.13,1927.036;Float;True;Spherical;World;False;DetailAlbedo;_DetailAlbedo;white;21;None;Mid Texture 0;_MidTexture0;white;-1;None;Bot Texture 0;_BotTexture0;white;-1;None;Detail Albedo;False;9;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;8;FLOAT;1;False;3;FLOAT;0.5;False;4;FLOAT;2;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-4080.923,-169.1204;Float;False;Property;_SnowUVScale;Snow UV Scale;14;0;Create;True;0;0;False;0;0.2;0.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-3165.961,-1971.626;Float;True;Property;_BaseColor;Base Color;0;0;Create;True;0;0;False;0;None;9f34a4f4648f1b04587be4dcdb27b4fd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;83;-4027.517,147.9058;Float;False;Property;_SnowNormalIntensity;Snow Normal Intensity;18;0;Create;True;0;0;False;0;5;1.5;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.TriplanarNode;81;-3675.836,20.31168;Float;True;Spherical;World;True;Snow Normal;_SnowNormal;white;13;None;Mid Texture 3;_MidTexture3;white;-1;None;Bot Texture 3;_BotTexture3;white;-1;None;Snow Normal;False;9;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;37;-798.3584,590.2997;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;8;-3168.162,-1566.825;Float;True;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;89;-3157.552,-1360.073;Float;True;Property;_Smoothness;Smoothness;5;0;Create;True;0;0;False;0;None;None;True;0;False;gray;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;65;-780.1109,-558.0598;Float;True;Overlay;True;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-3039.622,471.9649;Float;True;2;2;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TriplanarNode;80;-3685.619,-376.8319;Float;True;Spherical;World;False;Snow Albedo;_SnowAlbedo;white;12;None;Mid Texture 2;_MidTexture2;white;-1;None;Bot Texture 2;_BotTexture2;white;-1;None;Snow Albedo;False;9;0;SAMPLER2D;;False;5;FLOAT;1;False;1;SAMPLER2D;;False;6;FLOAT;0;False;2;SAMPLER2D;;False;7;FLOAT;0;False;8;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;72;-561.1338,-316.1002;Float;False;Property;_DetailAlbedoStrength;Detail Albedo Strength;25;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-3055.284,1793.948;Float;False;Property;_SnowAOCancellation;Snow AO Cancellation;19;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;104;-322.8526,608.9201;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;66;-470.8707,-715.8875;Float;False;Property;_UseDetailMap;Use Detail Map;13;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-2929.833,1690.286;Float;False;Constant;_Float1;Float 1;12;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;85;-2735.046,273.2147;Float;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;90;-2731.482,-1276.404;Float;False;Property;_SmoothnessinMetallic;Smoothness in Metallic?;8;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;16;-3562.235,-167.3979;Float;False;Property;_SnowColor;Snow Color;10;0;Create;True;0;0;False;0;0.8000001,0.8431373,0.8784314,0;0.8000001,0.8431373,0.8784314,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;12;-3167.275,-973.9344;Float;True;Property;_AmbientOcclusion;Ambient Occlusion;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;9;-3161.791,-1066.094;Float;False;Property;_SmoothnessStrength;Smoothness Strength;7;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-2744.919,-1618.138;Float;False;Constant;_Float3;Float 3;28;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;86;-2564.839,-105.7687;Float;False;Property;_UseSnowTexture;Use Snow Texture;11;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;9;1;FLOAT4;0,0,0,0;False;0;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;0,0,0,0;False;5;FLOAT4;0,0,0,0;False;6;FLOAT4;0,0,0,0;False;7;FLOAT4;0,0,0,0;False;8;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;57;-2647.598,1706.232;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;96;-117.6757,578.5697;Float;False;_snowMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;97;-143.8209,22.99179;Float;False;96;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-2325.619,-1246.948;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1220.289,-1320.722;Float;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;75;-134.1254,-720.2564;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;84;-2590.716,-337.9163;Float;False;Property;_UseSnowTexture;Use Snow Texture;6;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;42;196.6502,-144.4675;Float;True;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StaticSwitch;93;-2554.585,-1522.474;Float;False;Property;_UseMetallic;Use Metallic;9;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;46;203.8157,334.7113;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;87;198.8896,95.03945;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;13;202.3219,-418.5136;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;40;-999.2504,-1390.522;Float;False;Property;_UseMask;Use Mask;1;0;Create;True;0;0;False;0;0;0;1;True;;Toggle;2;Key0;Key1;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;945.6037,-140.1388;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Winter Environment/Standard Snow Cutout Two Sided;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;0;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;63;8;69;0
WireConnection;63;3;68;0
WireConnection;63;4;88;0
WireConnection;64;0;11;0
WireConnection;64;1;63;0
WireConnection;67;1;11;0
WireConnection;67;0;64;0
WireConnection;28;0;67;0
WireConnection;105;0;28;2
WireConnection;56;0;53;2
WireConnection;56;1;45;0
WireConnection;55;0;53;1
WireConnection;55;1;45;0
WireConnection;30;0;105;0
WireConnection;30;1;18;0
WireConnection;54;0;55;0
WireConnection;54;1;56;0
WireConnection;54;2;53;3
WireConnection;62;3;68;0
WireConnection;62;4;88;0
WireConnection;81;8;83;0
WireConnection;81;3;82;0
WireConnection;37;0;30;0
WireConnection;37;1;38;0
WireConnection;65;0;62;0
WireConnection;65;1;7;0
WireConnection;48;0;11;0
WireConnection;48;1;54;0
WireConnection;80;3;82;0
WireConnection;104;0;37;0
WireConnection;66;1;7;0
WireConnection;66;0;65;0
WireConnection;85;0;81;0
WireConnection;85;1;48;0
WireConnection;90;1;89;1
WireConnection;90;0;8;4
WireConnection;86;1;48;0
WireConnection;86;0;85;0
WireConnection;57;0;12;0
WireConnection;57;1;58;0
WireConnection;57;2;47;0
WireConnection;96;0;104;0
WireConnection;10;0;90;0
WireConnection;10;1;9;0
WireConnection;75;0;7;0
WireConnection;75;1;66;0
WireConnection;75;2;72;0
WireConnection;84;1;16;0
WireConnection;84;0;80;0
WireConnection;42;0;67;0
WireConnection;42;1;86;0
WireConnection;42;2;97;0
WireConnection;93;1;94;0
WireConnection;93;0;8;1
WireConnection;46;0;12;0
WireConnection;46;1;57;0
WireConnection;46;2;97;0
WireConnection;87;0;10;0
WireConnection;87;1;80;4
WireConnection;87;2;97;0
WireConnection;13;0;75;0
WireConnection;13;1;84;0
WireConnection;13;2;97;0
WireConnection;40;1;41;0
WireConnection;40;0;7;4
WireConnection;0;0;13;0
WireConnection;0;1;42;0
WireConnection;0;3;93;0
WireConnection;0;4;87;0
WireConnection;0;5;46;0
WireConnection;0;10;40;0
ASEEND*/
//CHKSM=30EFC8699E27BFC2CACD36E7432CB91A7949C59F