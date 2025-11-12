using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
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
    public string colorProperty = "";     // p.ej. "_Color" o vacío si no usás color
    public Slider rSlider;
    public Slider gSlider;
    public Slider bSlider;
    public Slider aSlider;

    [Header("Floats (sliders mapeados a propiedades)")]
    public List<FloatBinding> floatBindings = new();


    private UnityAction<float> _rCb, _gCb, _bCb, _aCb;
    private bool _colorHooked = false;

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
    void Start()
    {
        GetComponent<Renderer>().material.SetColor("_ColorStencil1", Color.red);
    }
    // ------- Internals -------
    private readonly List<(Renderer r, int matIndex)> _targets = new();
    private readonly Dictionary<Renderer, MaterialPropertyBlock> _mpbCache = new();
    private int _colorId;

    // ================== Lifecycle ==================
    private void OnEnable()
    {
        CachePropertyIds();
        HookUI(true);
        RebuildTargets();
        SceneManager.activeSceneChanged += OnSceneChanged;
    }

    private void OnDisable()
    {
        HookUI(false);            // ya remueve SOLO tus callbacks
        SceneManager.activeSceneChanged -= OnSceneChanged;
        _targets.Clear();
        _mpbCache.Clear();
    }

    private void OnValidate()
    {
        CachePropertyIds();
        // No hagas work pesado en edición; en play se reconstruye solo
    }

    private void OnSceneChanged(Scene a, Scene b) => RebuildTargets();

    private void CachePropertyIds()
    {
        _colorId = string.IsNullOrEmpty(colorProperty) ? 0 : Shader.PropertyToID(colorProperty);
        foreach (var fb in floatBindings)
        {
            fb.propId = Shader.PropertyToID(fb.propertyName);
        }
    }

    private void HookUI(bool on)
    {
        // Floats (queda igual que antes pero sin RemoveAllListeners global)
        foreach (var fb in floatBindings)
        {
            if (fb.slider == null) continue;

            // Primero remuevo mi callback si ya existía
            // Truco: guardo el delegado en el propio slider usando closure estable
            UnityAction<float> cb = null;
            cb = (v) => ApplyFloat(fb);

            // Para evitar duplicados, quito y agrego mi callback específico
            fb.slider.onValueChanged.RemoveListener(cb);
            if (on) fb.slider.onValueChanged.AddListener(cb);
        }

        // Color
        if (!string.IsNullOrEmpty(colorProperty))
        {
            if (!_colorHooked && on)
            {
                _rCb = _ => ApplyColorFromUI();
                _gCb = _ => ApplyColorFromUI();
                _bCb = _ => ApplyColorFromUI();
                _aCb = _ => ApplyColorFromUI();

                if (rSlider) rSlider.onValueChanged.AddListener(_rCb);
                if (gSlider) gSlider.onValueChanged.AddListener(_gCb);
                if (bSlider) bSlider.onValueChanged.AddListener(_bCb);
                if (aSlider) aSlider.onValueChanged.AddListener(_aCb);

                _colorHooked = true;

                // Opcional: desactivar navegación para evitar “saltos” de foco entre sliders
                TryDisableNavigation(rSlider);
                TryDisableNavigation(gSlider);
                TryDisableNavigation(bSlider);
                TryDisableNavigation(aSlider);
            }
            else if (_colorHooked && !on)
            {
                if (rSlider) rSlider.onValueChanged.RemoveListener(_rCb);
                if (gSlider) gSlider.onValueChanged.RemoveListener(_gCb);
                if (bSlider) bSlider.onValueChanged.RemoveListener(_bCb);
                if (aSlider) aSlider.onValueChanged.RemoveListener(_aCb);

                _colorHooked = false;
            }
        }
    }
    private void TryDisableNavigation(Slider s)
    {
        if (!s) return;
        var nav = s.navigation;
        nav.mode = Navigation.Mode.None;
        s.navigation = nav;
    }

    // ================== Target discovery ==================
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
                if (mats[i] == targetMaterial) // referencia exacta
                    _targets.Add((r, i));
            }
        }

        // Inicializar UI con valores actuales
        InitFloatSlidersFromCurrent();
        InitColorSlidersFromCurrent();
        // Aplicar una primera vez para asegurar sincronía visual
        ApplyAll();
    }

    // ================== Apply helpers ==================
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
        foreach (var fb in floatBindings)
            ApplyFloat(fb);

        if (!string.IsNullOrEmpty(colorProperty))
            ApplyColorFromUI();
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

        for (int i = 0; i < _targets.Count; i++)
        {
            var (r, mi) = _targets[i];
            if (!r) continue;
            var mpb = GetBlock(r);
            r.GetPropertyBlock(mpb, mi);
            mpb.SetFloat(fb.propId, v);
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

        if (!targetMaterial.HasProperty(_colorId))
        {
            Debug.LogWarning($"Material {targetMaterial.name} no tiene la propiedad {_colorId}.");
        }
        else
        {
            Debug.Log($"Seteando {_colorId} a {c} en material {targetMaterial.name}");
        }

        if (!usePropertyBlock)
        {
            if (targetMaterial && targetMaterial.HasProperty(_colorId))
                targetMaterial.SetColor(_colorId, c);
            return;
        }

        for (int i = 0; i < _targets.Count; i++)
        {
            var (rd, mi) = _targets[i];
            if (!rd) continue;
            var mpb = GetBlock(rd);
            rd.GetPropertyBlock(mpb, mi);
            mpb.SetColor(_colorId, c);
            rd.SetPropertyBlock(mpb, mi);
        }
    }

    // ================== Init UI from current values ==================
    private void InitFloatSlidersFromCurrent()
    {
        foreach (var fb in floatBindings)
        {
            if (fb.slider == null || fb.propId == 0) continue;

            // Configurar rangos del slider si no los tocaste
            if (fb.slider.minValue == 0f && fb.slider.maxValue == 1f)
            {
                fb.slider.minValue = 0f; // UI (0..1) por defecto
                fb.slider.maxValue = 1f;
            }

            float current = 0f;
            bool got = false;

            if (usePropertyBlock && _targets.Count > 0)
            {
                var (r, mi) = _targets[0];
                var mpb = GetBlock(r);
                r.GetPropertyBlock(mpb, mi);
                if (!mpb.isEmpty)
                {
                    current = mpb.GetFloat(fb.propId);
                    got = true;
                }
            }

            if (!got && targetMaterial && targetMaterial.HasProperty(fb.propId))
                current = targetMaterial.GetFloat(fb.propId);

            // Mapear al rango UI del slider
            float t = Mathf.InverseLerp(fb.sliderMin, fb.sliderMax, current);
            float sliderVal = Mathf.Lerp(fb.slider.minValue, fb.slider.maxValue, t);
            fb.slider.SetValueWithoutNotify(sliderVal);
        }
    }

    private void InitColorSlidersFromCurrent()
    {
        if (_colorId == 0) return;

        Color c = Color.white;
        bool got = false;

        if (usePropertyBlock && _targets.Count > 0)
        {
            var (r, mi) = _targets[0];
            var mpb = GetBlock(r);
            r.GetPropertyBlock(mpb, mi);
            if (!mpb.isEmpty)
            {
                c = mpb.GetColor(_colorId);
                got = true;
            }
        }

        if (!got && targetMaterial && targetMaterial.HasProperty(_colorId))
            c = targetMaterial.GetColor(_colorId);

        if (rSlider) rSlider.SetValueWithoutNotify(c.r);
        if (gSlider) gSlider.SetValueWithoutNotify(c.g);
        if (bSlider) bSlider.SetValueWithoutNotify(c.b);
        if (aSlider) aSlider.SetValueWithoutNotify(c.a);
    }
}