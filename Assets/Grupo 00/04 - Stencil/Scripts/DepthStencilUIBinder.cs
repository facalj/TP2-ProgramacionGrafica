using System;
using System.Linq;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.UI;

[DisallowMultipleComponent]
public sealed class DepthStencilUIBinder : MonoBehaviour
{
    [Header("Target")]
    [SerializeField] private Renderer targetRenderer;
    [Tooltip("Usar MaterialPropertyBlock en lugar de duplicar el Material")]
    [SerializeField] private bool usePropertyBlock = false;

    [Header("Material property names (deben existir en el shader)")]
    [SerializeField] private string zWriteProp = "_ZWrite";
    [SerializeField] private string zTestProp = "_ZTest";
    [SerializeField] private string stencilRefProp = "_Stencil";
    [SerializeField] private string stencilReadMaskProp = "_StencilReadMask";
    [SerializeField] private string stencilWriteMaskProp = "_StencilWriteMask";
    [SerializeField] private string stencilCompProp = "_StencilComp";
    [SerializeField] private string stencilPassProp = "_StencilPass";
    [SerializeField] private string stencilFailProp = "_StencilFail";
    [SerializeField] private string stencilZFailProp = "_StencilZFail";

    [Header("UI - Depth")]
    [SerializeField] private Toggle zWriteToggle;
    [SerializeField] private Dropdown zTestDropdown; 
    [Header("UI - Stencil (enteros)")]
    [SerializeField] private Slider stencilRefSlider;      
    [SerializeField] private Slider stencilReadMaskSlider; 
    [SerializeField] private Slider stencilWriteMaskSlider;

    [Header("UI - Stencil (operadores)")]
    [SerializeField] private Dropdown stencilCompDropdown; 
    [SerializeField] private Dropdown stencilPassDropdown;  
    [SerializeField] private Dropdown stencilFailDropdown; 
    [SerializeField] private Dropdown stencilZFailDropdown; 

    [Header("Opciones")]
    [SerializeField] private bool applyOnStart = true;
    [SerializeField] private bool syncUIFromMaterialOnStart = true;

    // --- Internals ---
    private Material _matInstance;
    private MaterialPropertyBlock _mpb;
    private Renderer _r;
    private static readonly string[] _compareNames = Enum.GetNames(typeof(CompareFunction));
    private static readonly string[] _stencilOpNames = Enum.GetNames(typeof(StencilOp));

    private void Awake()
    {
        _r = targetRenderer ? targetRenderer : GetComponent<Renderer>();
        if (_r == null)
        {
            Debug.LogError("[DepthStencilUIBinder] No hay Renderer asignado ni en el GameObject.");
            enabled = false;
            return;
        }

        if (usePropertyBlock)
        {
            _mpb = new MaterialPropertyBlock();
            _r.GetPropertyBlock(_mpb);
        }
        else
        {
            _matInstance = _r.material;
        }

        SetupDropdown(zTestDropdown, _compareNames);
        SetupDropdown(stencilCompDropdown, _compareNames);
        SetupDropdown(stencilPassDropdown, _stencilOpNames);
        SetupDropdown(stencilFailDropdown, _stencilOpNames);
        SetupDropdown(stencilZFailDropdown, _stencilOpNames);

        HookUI(true);
    }

    private void Start()
    {
        if (syncUIFromMaterialOnStart)
            SyncUIFromMaterial();

        if (applyOnStart)
            ApplyAll();
    }

    private void OnDestroy()
    {
        HookUI(false);
    }
    private void HookUI(bool on)
    {
        if (zWriteToggle)
        {
            zWriteToggle.onValueChanged.RemoveAllListeners();
            if (on) zWriteToggle.onValueChanged.AddListener(_ => ApplyDepth());
        }
        if (zTestDropdown)
        {
            zTestDropdown.onValueChanged.RemoveAllListeners();
            if (on) zTestDropdown.onValueChanged.AddListener(_ => ApplyDepth());
        }

        void HookSlider(Slider s, Action cb)
        {
            if (!s) return;
            s.onValueChanged.RemoveAllListeners();
            if (on) s.onValueChanged.AddListener(_ => cb());
        }

        HookSlider(stencilRefSlider, ApplyStencil);
        HookSlider(stencilReadMaskSlider, ApplyStencil);
        HookSlider(stencilWriteMaskSlider, ApplyStencil);

        void HookDrop(Dropdown d, Action cb)
        {
            if (!d) return;
            d.onValueChanged.RemoveAllListeners();
            if (on) d.onValueChanged.AddListener(_ => cb());
        }

        HookDrop(stencilCompDropdown, ApplyStencil);
        HookDrop(stencilPassDropdown, ApplyStencil);
        HookDrop(stencilFailDropdown, ApplyStencil);
        HookDrop(stencilZFailDropdown, ApplyStencil);
    }

    private static void SetupDropdown(Dropdown dd, string[] names)
    {
        if (!dd) return;
        dd.options = names.Select(n => new Dropdown.OptionData(n)).ToList();
        dd.RefreshShownValue();
    }

    [ContextMenu("Apply All")]
    public void ApplyAll()
    {
        ApplyDepth();
        ApplyStencil();
        PushIfMPB();
    }

    public void ApplyDepth()
    {
        if (!HasMat()) return;

        int zwrite = zWriteToggle ? (zWriteToggle.isOn ? 1 : 0) : GetIntFromMat(zWriteProp, 1);
        int ztest = zTestDropdown ? zTestDropdown.value : GetIntFromMat(zTestProp, (int)CompareFunction.LessEqual);

        SetInt(zWriteProp, zwrite);
        SetInt(zTestProp, ztest);
        PushIfMPB();
    }

    public void ApplyStencil()
    {
        if (!HasMat()) return;

        int sRef = stencilRefSlider ? Mathf.RoundToInt(stencilRefSlider.value) : GetIntFromMat(stencilRefProp, 1);
        int sRMask = stencilReadMaskSlider ? Mathf.RoundToInt(stencilReadMaskSlider.value) : GetIntFromMat(stencilReadMaskProp, 255);
        int sWMask = stencilWriteMaskSlider ? Mathf.RoundToInt(stencilWriteMaskSlider.value) : GetIntFromMat(stencilWriteMaskProp, 255);

        int comp = stencilCompDropdown ? stencilCompDropdown.value : GetIntFromMat(stencilCompProp, (int)CompareFunction.Always);
        int pass = stencilPassDropdown ? stencilPassDropdown.value : GetIntFromMat(stencilPassProp, (int)StencilOp.Keep);
        int fail = stencilFailDropdown ? stencilFailDropdown.value : GetIntFromMat(stencilFailProp, (int)StencilOp.Keep);
        int zfail = stencilZFailDropdown ? stencilZFailDropdown.value : GetIntFromMat(stencilZFailProp, (int)StencilOp.Keep);

        SetInt(stencilRefProp, sRef);
        SetInt(stencilReadMaskProp, sRMask);
        SetInt(stencilWriteMaskProp, sWMask);
        SetInt(stencilCompProp, comp);
        SetInt(stencilPassProp, pass);
        SetInt(stencilFailProp, fail);
        SetInt(stencilZFailProp, zfail);

        PushIfMPB();
    }

    [ContextMenu("Sync UI From Material")]
    public void SyncUIFromMaterial()
    {
        if (!HasMat()) return;

        SetToggleWithoutNotify(zWriteToggle, GetIntFromMat(zWriteProp, 1) != 0);
        SetDropdownWithoutNotify(zTestDropdown, GetIntFromMat(zTestProp, (int)CompareFunction.LessEqual));

        SetSliderWithoutNotify(stencilRefSlider, GetIntFromMat(stencilRefProp, 1));
        SetSliderWithoutNotify(stencilReadMaskSlider, GetIntFromMat(stencilReadMaskProp, 255));
        SetSliderWithoutNotify(stencilWriteMaskSlider, GetIntFromMat(stencilWriteMaskProp, 255));

        SetDropdownWithoutNotify(stencilCompDropdown, GetIntFromMat(stencilCompProp, (int)CompareFunction.Always));
        SetDropdownWithoutNotify(stencilPassDropdown, GetIntFromMat(stencilPassProp, (int)StencilOp.Keep));
        SetDropdownWithoutNotify(stencilFailDropdown, GetIntFromMat(stencilFailProp, (int)StencilOp.Keep));
        SetDropdownWithoutNotify(stencilZFailDropdown, GetIntFromMat(stencilZFailProp, (int)StencilOp.Keep));
    }

    private bool HasMat()
    {
        if (_r == null) return false;
        if (!usePropertyBlock && _matInstance == null) return false;
        return true;
    }

    private int GetIntFromMat(string prop, int fallback)
    {
        if (string.IsNullOrEmpty(prop)) return fallback;
        if (_matInstance != null && _matInstance.HasProperty(prop))
            return _matInstance.GetInt(prop);
        return fallback;
    }

    private void SetInt(string prop, int value)
    {
        if (string.IsNullOrEmpty(prop)) return;

        if (usePropertyBlock)
        {
            _r.GetPropertyBlock(_mpb);
            _mpb.SetFloat(prop, value);
        }
        else
        {
            if (_matInstance) _matInstance.SetInt(prop, value);
        }
    }

    private void PushIfMPB()
    {
        if (usePropertyBlock && _r != null && _mpb != null)
            _r.SetPropertyBlock(_mpb);
    }


    private static void SetToggleWithoutNotify(Toggle t, bool v)
    {
        if (!t) return;
        var prev = t.onValueChanged;
        t.onValueChanged = new Toggle.ToggleEvent();
        t.isOn = v;
        t.onValueChanged = prev;
    }

    private static void SetDropdownWithoutNotify(Dropdown d, int idx)
    {
        if (!d) return;
        var prev = d.onValueChanged;
        d.onValueChanged = new Dropdown.DropdownEvent();
        d.value = Mathf.Clamp(idx, 0, Mathf.Max(0, d.options.Count - 1));
        d.RefreshShownValue();
        d.onValueChanged = prev;
    }

    private static void SetSliderWithoutNotify(Slider s, float v)
    {
        if (!s) return;
        var prev = s.onValueChanged;
        s.onValueChanged = new Slider.SliderEvent();
        s.value = Mathf.Clamp(v, s.minValue, s.maxValue);
        s.onValueChanged = prev;
    }
}
