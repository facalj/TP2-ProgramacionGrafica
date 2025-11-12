using UnityEngine;
using UnityEngine.UI;
using System;
using System.Collections.Generic;

[RequireComponent(typeof(Camera))]
public class PostProcessSwitcherWithSliders : MonoBehaviour
{
    [Header("3 MATERIALES DE POST-PROCESO")]
    [SerializeField] private Material mat1;
    [SerializeField] private Material mat2;
    [SerializeField] private Material mat3;

    [Header("SLIDERS (Color)")]
    public string colorProperty = "_Tint";
    public Slider rSlider, gSlider, bSlider, aSlider;

    
    [Serializable]
    public class FloatBinding
    {
        public string propertyName = "_Intensity";
        public Slider slider;
        public float min = 0f, max = 1f;
        [HideInInspector] public int id;
    }
    public List<FloatBinding> floatBindings = new();

    private Material[] materials;
    private int currentIndex = 0;
    private Material Current => materials[currentIndex];

    private void Awake()
    {
        materials = new Material[] { mat1, mat2, mat3 };
        ValidateMaterials();

        CachePropertyIds();
        HookSliders(true);
        SyncSlidersToCurrentMaterial();
    }

    private void OnDestroy() => HookSliders(false);

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1) || Input.GetKeyDown(KeyCode.Keypad1)) SwitchTo(0);
        if (Input.GetKeyDown(KeyCode.Alpha2) || Input.GetKeyDown(KeyCode.Keypad2)) SwitchTo(1);
        if (Input.GetKeyDown(KeyCode.Alpha3) || Input.GetKeyDown(KeyCode.Keypad3)) SwitchTo(2);
    }

    private void SwitchTo(int index)
    {
        if (index < 0 || index >= materials.Length || materials[index] == null) return;

        currentIndex = index;
        SyncSlidersToCurrentMaterial();
        Debug.Log($"Post-Material: {materials[index].name}");
    }

    private void ValidateMaterials()
    {
        for (int i = 0; i < materials.Length; i++)
        {
            if (materials[i] == null)
                Debug.LogWarning($"Material {i + 1} NO asignado.");
        }
    }

    private void CachePropertyIds()
    {
        foreach (var fb in floatBindings)
            fb.id = Shader.PropertyToID(fb.propertyName);
    }

    private void HookSliders(bool on)
    {
        // Floats
        foreach (var fb in floatBindings)
        {
            if (!fb.slider) continue;
            if (on) fb.slider.onValueChanged.AddListener(v => SetFloat(fb, v));
            else fb.slider.onValueChanged.RemoveAllListeners();
        }

        // Color
        if (!string.IsNullOrEmpty(colorProperty))
        {
            var id = Shader.PropertyToID(colorProperty);
            Action update = () =>
            {
                if (Current && Current.HasProperty(id))
                    Current.SetColor(id, GetColorFromSliders());
            };

            if (on)
            {
                if (rSlider) rSlider.onValueChanged.AddListener(_ => update());
                if (gSlider) gSlider.onValueChanged.AddListener(_ => update());
                if (bSlider) bSlider.onValueChanged.AddListener(_ => update());
                if (aSlider) aSlider.onValueChanged.AddListener(_ => update());
            }
            else
            {
                if (rSlider) rSlider.onValueChanged.RemoveAllListeners();
                if (gSlider) gSlider.onValueChanged.RemoveAllListeners();
                if (bSlider) bSlider.onValueChanged.RemoveAllListeners();
                if (aSlider) aSlider.onValueChanged.RemoveAllListeners();
            }
        }
    }

    private void SetFloat(FloatBinding fb, float sliderValue)
    {
        if (!Current || !Current.HasProperty(fb.id)) return;
        float t = Mathf.InverseLerp(fb.slider.minValue, fb.slider.maxValue, sliderValue);
        float value = Mathf.Lerp(fb.min, fb.max, t);
        Current.SetFloat(fb.id, value);
    }

    private Color GetColorFromSliders()
    {
        return new Color(
            rSlider ? rSlider.value : 1f,
            gSlider ? gSlider.value : 1f,
            bSlider ? bSlider.value : 1f,
            aSlider ? aSlider.value : 1f
        );
    }

    private void SyncSlidersToCurrentMaterial()
    {
        if (!Current) return;

        // Floats
        foreach (var fb in floatBindings)
        {
            if (!fb.slider || !Current.HasProperty(fb.id)) continue;
            float val = Current.GetFloat(fb.id);
            float t = Mathf.InverseLerp(fb.min, fb.max, val);
            float sliderVal = Mathf.Lerp(fb.slider.minValue, fb.slider.maxValue, t);
            fb.slider.value = sliderVal;
        }

        // Color
        if (!string.IsNullOrEmpty(colorProperty))
        {
            var id = Shader.PropertyToID(colorProperty);
            if (Current.HasProperty(id))
            {
                Color c = Current.GetColor(id);
                if (rSlider) rSlider.value = c.r;
                if (gSlider) gSlider.value = c.g;
                if (bSlider) bSlider.value = c.b;
                if (aSlider) aSlider.value = c.a;
            }
        }
    }

    // POST-PROCESO
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Current != null)
            Graphics.Blit(src, dest, Current);
        else
            Graphics.Blit(src, dest);
    }
}
