// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PPInvert"
{
	Properties
	{
		_RT("RT", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _RT;
		uniform float4 _RT_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_RT = i.uv_texcoord * _RT_ST.xy + _RT_ST.zw;
			float pixelWidth32 =  1.0f / 64.0;
			float pixelHeight32 = 1.0f / 64.0;
			half2 pixelateduv32 = half2((int)(uv_RT.x / pixelWidth32) * pixelWidth32, (int)(uv_RT.y / pixelHeight32) * pixelHeight32);
			o.Albedo = ( 1.0 - tex2D( _RT, pixelateduv32 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
0;522;1327;469;1879.5;202.8631;2.149013;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;30;-990.9985,26.11439;Inherit;True;Property;_RT;RT;0;0;Create;True;0;0;0;False;0;False;2ba17cf073a14dd44833f986406f2a3c;52fe2e5eb6578154fbe703a3c07f0301;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TextureCoordinatesNode;31;-747.3424,198.4494;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCPixelate;32;-512.8314,196.7248;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;64;False;2;FLOAT;64;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;33;-235.8001,21.26985;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;36;92.40833,36.78934;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;480.6244,42.40138;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;PPInvert;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;31;2;30;0
WireConnection;32;0;31;0
WireConnection;33;0;30;0
WireConnection;33;1;32;0
WireConnection;36;0;33;0
WireConnection;0;0;36;0
ASEEND*/
//CHKSM=12BAA336D5E723C2F30CCBF8F1A379080C7A18F7