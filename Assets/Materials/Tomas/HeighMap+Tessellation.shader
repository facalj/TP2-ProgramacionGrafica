// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "HeighMap+Tessellation"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_TextureSample1("Texture Sample 1", 2D) = "white" {}
		_HeightMultiplier("HeightMultiplier", Range( 0 , 5)) = 1
		_EdgeLength("EdgeLength", Range( 0 , 3)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureSample0;
		uniform float _HeightMultiplier;
		uniform sampler2D _TextureSample1;
		uniform float _EdgeLength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float2 panner32 = ( _Time.y * float2( 0.1,0 ) + v.texcoord.xy);
			float4 tex2DNode3 = tex2Dlod( _TextureSample0, float4( panner32, 0, 0.0) );
			float3 ase_vertexNormal = v.normal.xyz;
			float4 smoothstepResult48 = smoothstep( float4( 0,0,0,0 ) , float4( 1,1,1,0 ) , ( ( tex2DNode3 * ( _HeightMultiplier / 10.0 ) ) * float4( ase_vertexNormal , 0.0 ) ));
			v.vertex.xyz += smoothstepResult48.rgb;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 panner32 = ( _Time.y * float2( 0.1,0 ) + i.uv_texcoord);
			float4 tex2DNode3 = tex2D( _TextureSample0, panner32 );
			o.Normal = tex2DNode3.rgb;
			o.Albedo = tex2D( _TextureSample1, panner32 ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
351;73;1060;611;2024.717;174.2088;2.426192;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;33;-1155.413,152.1547;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;37;-1214.068,-106.8064;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;36;-1193.041,11.60745;Inherit;False;Constant;_RotationSpeed;RotationSpeed;6;0;Create;True;0;0;0;False;0;False;0.1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode;32;-971.7062,-27.12599;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-839.1952,493.4205;Inherit;False;Property;_HeightMultiplier;HeightMultiplier;2;0;Create;True;0;0;0;False;0;False;1;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-741.408,271.8287;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;715f882cc0e46fd429f7d039c0f9600a;715f882cc0e46fd429f7d039c0f9600a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;38;-518.2428,500.1667;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-403.0562,280.4597;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;39;-317.0598,463.953;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-233.0776,280.4565;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-34.52054,431.3835;Inherit;False;Property;_EdgeLength;EdgeLength;3;0;Create;True;0;0;0;False;0;False;1;0.3214286;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;13;74.68932,-45.68085;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;6312ad43df5e5a84db17ba86d9adacf0;6312ad43df5e5a84db17ba86d9adacf0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;49;-412.193,118.2113;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;48;-21.83038,280.8736;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,1,1,0;False;1;COLOR;0
Node;AmplifyShaderEditor.EdgeLengthTessNode;44;263.4998,431.975;Inherit;False;1;0;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;520.3716,7.882338;Float;False;True;-1;6;ASEMaterialInspector;0;0;Standard;HeighMap+Tessellation;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;15;10;25;False;1;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;32;0;37;0
WireConnection;32;2;36;0
WireConnection;32;1;33;0
WireConnection;3;1;32;0
WireConnection;38;0;14;0
WireConnection;11;0;3;0
WireConnection;11;1;38;0
WireConnection;28;0;11;0
WireConnection;28;1;39;0
WireConnection;13;1;32;0
WireConnection;49;0;3;0
WireConnection;48;0;28;0
WireConnection;44;0;43;0
WireConnection;0;0;13;0
WireConnection;0;1;49;0
WireConnection;0;11;48;0
WireConnection;0;14;44;0
ASEEND*/
//CHKSM=F837BE12F2796C90B966CA49857F9ABFDA82CF72