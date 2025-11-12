using UnityEngine;
using UnityEngine.Rendering;

public static class MaterialDepthStencilUtil
{
    public static void SetDepth(Material m, bool zwrite, CompareFunction ztest)
    {
        m.SetInt("_ZWrite", zwrite ? 1 : 0);
        m.SetInt("_ZTest", (int)ztest);
    }

    public static void SetStencilBasic(
        Material m,
        int reference = 1,
        int readMask = 255,
        int writeMask = 255,
        CompareFunction comp = CompareFunction.Always,
        StencilOp pass = StencilOp.Keep,
        StencilOp fail = StencilOp.Keep,
        StencilOp zfail = StencilOp.Keep)
    {
        m.SetInt("_Stencil", reference);
        m.SetInt("_StencilReadMask", readMask);
        m.SetInt("_StencilWriteMask", writeMask);
        m.SetInt("_StencilComp", (int)comp);
        m.SetInt("_StencilPass", (int)pass);
        m.SetInt("_StencilFail", (int)fail);
        m.SetInt("_StencilZFail", (int)zfail);
    }

    public static void SetStencilFront(
        Material m, CompareFunction comp, StencilOp pass, StencilOp fail, StencilOp zfail)
    {
        m.SetInt("_StencilCompFront", (int)comp);
        m.SetInt("_StencilPassFront", (int)pass);
        m.SetInt("_StencilFailFront", (int)fail);
        m.SetInt("_StencilZFailFront", (int)zfail);
    }

    public static void SetStencilBack(
        Material m, CompareFunction comp, StencilOp pass, StencilOp fail, StencilOp zfail)
    {
        m.SetInt("_StencilCompBack", (int)comp);
        m.SetInt("_StencilPassBack", (int)pass);
        m.SetInt("_StencilFailBack", (int)fail);
        m.SetInt("_StencilZFailBack", (int)zfail);
    }
}
