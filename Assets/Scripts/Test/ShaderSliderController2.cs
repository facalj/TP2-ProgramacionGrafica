using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

[DisallowMultipleComponent]
public class ShaderSliderController2 : MonoBehaviour
{
    [Header("Material a controlar (arrastrar aquí)")]
    public Material targetMaterial;

    [Tooltip("OFF = Cambia el Material (global). ON = Override por Renderer con MaterialPropertyBlock.")]
    public bool usePropertyBlock = false;

    [Header("Opcional: Color RGBA (0..1)")]
    public string colorProperty = "";
    public Slider rSlider;
    public Slider gSlider;
    public Slider bSlider;
    public Slider aSlider;

    [Header("Floats (sliders mapeados a propiedades)")]
    public List<FloatBinding> floatBindings = new();

    [Header("Vector2 (dos sliders por propiedad)")]
    public List<Vector2Binding> vector2Bindings = new();

    [Serializable]
    public class FloatBinding
    {
        [Tooltip("Reference Name en ASE (p.ej. _DissolveAmount)")]
        public string propertyName = "_MyFloat";
        public Slider slider;
        public float sliderMin = 0f;
        public float sliderMax = 1f;
        [HideInInspector] public int propId;
    }

    [Serializable]
    public class Vector2Binding
    {
        [Tooltip("Reference Name en ASE (p.ej. _MyVector2)")]
        public string propertyName = "_MyVector2";
        public Slider xSlider;
        public Slider ySlider;
        public Vector2 min = Vector2.zero;
        public Vector2 max = Vector2.one;
        [HideInInspector] public int propId;
    }

    private readonly List<(Renderer r, int matIndex)> _targets = new();
    private readonly Dictionary<Renderer, MaterialPropertyBlock> _mpbCache = new();
    private int _colorId;

    private void OnEnable()
    {
        CachePropertyIds();
        HookUI(true);
        RebuildTargets();
        SceneManager.activeSceneChanged += OnSceneChanged;
    }

    private void OnDisable()
    {
        HookUI(false);
        SceneManager.activeSceneChanged -= OnSceneChanged;
        _targets.Clear();
        _mpbCache.Clear();
    }

    private void OnValidate() => CachePropertyIds();

    private void OnSceneChanged(Scene a, Scene b) => RebuildTargets();

    private void CachePropertyIds()
    {
        _colorId = string.IsNullOrEmpty(colorProperty) ? 0 : Shader.PropertyToID(colorProperty);
        foreach (var fb in floatBindings) fb.propId = Shader.PropertyToID(fb.propertyName);
        foreach (var vb in vector2Bindings) vb.propId = Shader.PropertyToID(vb.propertyName);
    }

    private void HookUI(bool on)
    {
        void Hook(Slider s, Action<float> cb)
        {
            if (!s) return;
            if (on) s.onValueChanged.AddListener(v => cb(v));
            else s.onValueChanged.RemoveAllListeners();
        }

        foreach (var fb in floatBindings)
            Hook(fb.slider, _ => ApplyFloat(fb));

        foreach (var vb in vector2Bindings)
        {
            Hook(vb.xSlider, _ => ApplyVector2(vb));
            Hook(vb.ySlider, _ => ApplyVector2(vb));
        }

        if (!string.IsNullOrEmpty(colorProperty))
        {
            Hook(rSlider, _ => ApplyColorFromUI());
            Hook(gSlider, _ => ApplyColorFromUI());
            Hook(bSlider, _ => ApplyColorFromUI());
            Hook(aSlider, _ => ApplyColorFromUI());
        }
    }

    private void RebuildTargets()
    {
        _targets.Clear();
        _mpbCache.Clear();

        if (!targetMaterial) return;

        var renderers = FindObjectsOfType<Renderer>(true);
        foreach (var r in renderers)
        {
            var mats = r.sharedMaterials;
            for (int i = 0; i < mats.Length; i++)
            {
                if (mats[i] == targetMaterial)
                    _targets.Add((r, i));
            }
        }

        InitFloatSlidersFromCurrent();
        InitColorSlidersFromCurrent();
        InitVector2SlidersFromCurrent();

        ApplyAll();
    }

    private MaterialPropertyBlock GetBlock(Renderer r)
    {
        if (!_mpbCache.TryGetValue(r, out var mpb))
        {
            mpb = new MaterialPropertyBlock();
            _mpbCache[r] = mpb;
        }
        return mpb;
    }

    private void ApplyAll()
    {
        foreach (var fb in floatBindings) ApplyFloat(fb);
        foreach (var vb in vector2Bindings) ApplyVector2(vb);
        if (!string.IsNullOrEmpty(colorProperty)) ApplyColorFromUI();
    }

    private void ApplyFloat(FloatBinding fb)
    {
        if (fb.slider == null || fb.propId == 0) return;
        float t = Mathf.InverseLerp(fb.slider.minValue, fb.slider.maxValue, fb.slider.value);
        float v = Mathf.Lerp(fb.sliderMin, fb.sliderMax, t);

        if (!usePropertyBlock)
        {
            if (targetMaterial && targetMaterial.HasProperty(fb.propId))
                targetMaterial.SetFloat(fb.propId, v);
            return;
        }

        foreach (var (r, mi) in _targets)
        {
            if (!r) continue;
            var mpb = GetBlock(r);
            r.GetPropertyBlock(mpb, mi);
            mpb.SetFloat(fb.propId, v);
            r.SetPropertyBlock(mpb, mi);
        }
    }

    private void ApplyVector2(Vector2Binding vb)
    {
        if (vb.xSlider == null || vb.ySlider == null || vb.propId == 0) return;

        float tx = Mathf.InverseLerp(vb.xSlider.minValue, vb.xSlider.maxValue, vb.xSlider.value);
        float ty = Mathf.InverseLerp(vb.ySlider.minValue, vb.ySlider.maxValue, vb.ySlider.value);

        float vx = Mathf.Lerp(vb.min.x, vb.max.x, tx);
        float vy = Mathf.Lerp(vb.min.y, vb.max.y, ty);
        var vec = new Vector2(vx, vy);

        if (!usePropertyBlock)
        {
            if (targetMaterial && targetMaterial.HasProperty(vb.propId))
                targetMaterial.SetVector(vb.propId, vec);
            return;
        }

        foreach (var (r, mi) in _targets)
        {
            if (!r) continue;
            var mpb = GetBlock(r);
            r.GetPropertyBlock(mpb, mi);
            mpb.SetVector(vb.propId, vec);
            r.SetPropertyBlock(mpb, mi);
        }
    }

    private void ApplyColorFromUI()
    {
        if (_colorId == 0) return;
        float r = rSlider ? rSlider.value : 1f;
        float g = gSlider ? gSlider.value : 1f;
        float b = bSlider ? bSlider.value : 1f;
        float a = aSlider ? aSlider.value : 1f;
        var c = new Color(r, g, b, a);

        if (!usePropertyBlock)
        {
            if (targetMaterial && targetMaterial.HasProperty(_colorId))
                targetMaterial.SetColor(_colorId, c);
            return;
        }

        foreach (var (rd, mi) in _targets)
        {
            if (!rd) continue;
            var mpb = GetBlock(rd);
            rd.GetPropertyBlock(mpb, mi);
            mpb.SetColor(_colorId, c);
            rd.SetPropertyBlock(mpb, mi);
        }
    }

    private void InitFloatSlidersFromCurrent()
    {
        foreach (var fb in floatBindings)
        {
            if (fb.slider == null || fb.propId == 0) continue;

            float current = targetMaterial.HasProperty(fb.propId) ? targetMaterial.GetFloat(fb.propId) : 0f;
            float t = Mathf.InverseLerp(fb.sliderMin, fb.sliderMax, current);
            float sliderVal = Mathf.Lerp(fb.slider.minValue, fb.slider.maxValue, t);
            fb.slider.SetValueWithoutNotify(sliderVal);
        }
    }

    private void InitVector2SlidersFromCurrent()
    {
        foreach (var vb in vector2Bindings)
        {
            if (vb.xSlider == null || vb.ySlider == null || vb.propId == 0) continue;

            Vector4 current = targetMaterial.HasProperty(vb.propId) ? targetMaterial.GetVector(vb.propId) : Vector4.zero;

            float tx = Mathf.InverseLerp(vb.min.x, vb.max.x, current.x);
            float ty = Mathf.InverseLerp(vb.min.y, vb.max.y, current.y);

            float sliderX = Mathf.Lerp(vb.xSlider.minValue, vb.xSlider.maxValue, tx);
            float sliderY = Mathf.Lerp(vb.ySlider.minValue, vb.ySlider.maxValue, ty);

            vb.xSlider.SetValueWithoutNotify(sliderX);
            vb.ySlider.SetValueWithoutNotify(sliderY);
        }
    }

    private void InitColorSlidersFromCurrent()
    {
        if (_colorId == 0) return;

        Color c = targetMaterial.HasProperty(_colorId) ? targetMaterial.GetColor(_colorId) : Color.white;

        if (rSlider) rSlider.SetValueWithoutNotify(c.r);
        if (gSlider) gSlider.SetValueWithoutNotify(c.g);
        if (bSlider) bSlider.SetValueWithoutNotify(c.b);
        if (aSlider) aSlider.SetValueWithoutNotify(c.a);
    }
}
