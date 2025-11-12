using UnityEngine;
using UnityEngine.Rendering;

[DisallowMultipleComponent]
public sealed class DepthStencilController : MonoBehaviour
{
    [Header("Target")]
    [SerializeField] private Renderer targetRenderer;
    private Material targetMaterial;

    [Header("Depth Settings")]
    public bool zWrite = true;
    public CompareFunction zTest = CompareFunction.LessEqual;

    [Header("Stencil Settings")]
    public int reference = 1;
    public int readMask = 255;
    public int writeMask = 255;
    public CompareFunction comparison = CompareFunction.Always;
    public StencilOp pass = StencilOp.Keep;
    public StencilOp fail = StencilOp.Keep;
    public StencilOp zFail = StencilOp.Keep;

    private void Awake()
    {
        if (targetRenderer == null)
            targetRenderer = GetComponent<Renderer>();

        if (targetRenderer != null)
            targetMaterial = targetRenderer.material;
    }

    private void Start()
    {
        ApplyDepth();
        ApplyStencil();
    }

    [ContextMenu("Apply Depth & Stencil")]
    public void ApplyAll()
    {
        ApplyDepth();
        ApplyStencil();
    }

    public void ApplyDepth()
    {
        if (targetMaterial == null) return;

        targetMaterial.SetInt("_ZWrite", zWrite ? 1 : 0);
        targetMaterial.SetInt("_ZTest", (int)zTest);
    }

    public void ApplyStencil()
    {
        if (targetMaterial == null) return;

        targetMaterial.SetInt("_Stencil", reference);
        targetMaterial.SetInt("_StencilReadMask", readMask);
        targetMaterial.SetInt("_StencilWriteMask", writeMask);
        targetMaterial.SetInt("_StencilComp", (int)comparison);
        targetMaterial.SetInt("_StencilPass", (int)pass);
        targetMaterial.SetInt("_StencilFail", (int)fail);
        targetMaterial.SetInt("_StencilZFail", (int)zFail);
    }

    public void SetStencilMode(CompareFunction comp, StencilOp passOp)
    {
        comparison = comp;
        pass = passOp;
        ApplyStencil();
    }
}
