// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/RenderTargetShader"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_DistortionAmount0("_DistortionAmount0", Float) = 0
		_LineDensity("LineDensity", Float) = 100
		_PatternAmount("PatternAmount", Float) = 0.1
		_PixelDensity("PixelDensity", Float) = 200
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureSample0;
		uniform float _PixelDensity;
		uniform float _DistortionAmount0;
		uniform float _LineDensity;
		uniform float _PatternAmount;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float smoothstepResult42 = smoothstep( 0.0 , 1.0 , frac( ( ( (i.uv_texcoord).x + ( _Time.y * ( _DistortionAmount0 / 10.0 ) ) ) * _LineDensity ) ));
			float4 temp_cast_0 = (( smoothstepResult42 * _PatternAmount )).xxxx;
			float4 lerpResult45 = lerp( tex2D( _TextureSample0, ( floor( ( i.uv_texcoord * _PixelDensity ) ) / _PixelDensity ) ) , temp_cast_0 , _DistortionAmount0);
			float dotResult5 = dot( lerpResult45 , float4( float3(0.299,0.587,0.114) , 0.0 ) );
			float3 temp_cast_2 = (dotResult5).xxx;
			o.Albedo = temp_cast_2;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
8;74;1904;937;2970.75;706.5923;1.60253;True;True
Node;AmplifyShaderEditor.RangedFloatNode;46;-2131.479,486.1706;Inherit;False;Property;_DistortionAmount0;_DistortionAmount0;1;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;19;-1922.279,282.8297;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;18;-2091.022,146.3872;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;48;-1923.335,389.9735;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1745.279,281.8297;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;27;-1804.33,150.5202;Inherit;False;True;False;True;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1518.261,271.518;Inherit;False;Property;_LineDensity;LineDensity;2;0;Create;True;0;0;0;False;0;False;100;100;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-1508.94,154.1574;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1676.982,-41.49692;Inherit;False;Property;_PixelDensity;PixelDensity;4;0;Create;True;0;0;0;False;0;False;200;200;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-1750.982,-176.4969;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1296.811,155.198;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1491.982,-173.4969;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;30;-1140.811,155.198;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FloorOpNode;15;-1329.151,-175.7627;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-956.3696,335.7622;Inherit;False;Property;_PatternAmount;PatternAmount;3;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;42;-970.334,154.1917;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;16;-1160.151,-175.7627;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;47;-560.8494,411.8796;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-713.1976,151.6856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-996,-200;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;903b7072a7358ae4fb64d3cea4d1b4a1;903b7072a7358ae4fb64d3cea4d1b4a1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;6;-172.0216,-81.299;Inherit;False;Constant;_EstandarDeTVBW;EstandarDeTV B&W;1;0;Create;True;0;0;0;False;0;False;0.299,0.587,0.114;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;45;-483.6349,-195.3198;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;5;102.4745,-189.0427;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;417.0144,-202.2393;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Custom/RenderTargetShader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;48;0;46;0
WireConnection;21;0;19;0
WireConnection;21;1;48;0
WireConnection;27;0;18;0
WireConnection;36;0;27;0
WireConnection;36;1;21;0
WireConnection;29;0;36;0
WireConnection;29;1;28;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;30;0;29;0
WireConnection;15;0;11;0
WireConnection;42;0;30;0
WireConnection;16;0;15;0
WireConnection;16;1;10;0
WireConnection;47;0;46;0
WireConnection;43;0;42;0
WireConnection;43;1;44;0
WireConnection;2;1;16;0
WireConnection;45;0;2;0
WireConnection;45;1;43;0
WireConnection;45;2;47;0
WireConnection;5;0;45;0
WireConnection;5;1;6;0
WireConnection;0;0;5;0
ASEEND*/
//CHKSM=9794738CDABEE6520AC580D96DF222D5326350AA