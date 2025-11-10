using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

[DisallowMultipleComponent]
public class LightSliderController1 : MonoBehaviour
{
    [Header("Luz a controlar")]
    public Light targetLight;

    [Header("Sliders de Color (valores de 0 a 1)")]
    public Slider rSlider;
    public Slider gSlider;
    public Slider bSlider;
    public Slider aSlider; // opcional, sin uso en Light.color

    private UnityAction<float> _rCb, _gCb, _bCb, _aCb;
    private bool _colorHooked = false;

    private void OnEnable()
    {
        HookUI(true);
        InitColorSlidersFromCurrent();
    }

    private void OnDisable()
    {
        HookUI(false);
    }

    private void HookUI(bool on)
    {
        if (targetLight == null) return;

        // Color
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

    private void TryDisableNavigation(Slider s)
    {
        if (!s) return;
        var nav = s.navigation;
        nav.mode = Navigation.Mode.None;
        s.navigation = nav;
    }

    private void InitColorSlidersFromCurrent()
    {
        if (targetLight == null) return;

        Color c = targetLight.color;

        if (rSlider) rSlider.SetValueWithoutNotify(c.r);
        if (gSlider) gSlider.SetValueWithoutNotify(c.g);
        if (bSlider) bSlider.SetValueWithoutNotify(c.b);
        if (aSlider) aSlider.SetValueWithoutNotify(1f); // No tiene uso real
    }

    private void ApplyColorFromUI()
    {
        if (targetLight == null) return;

        float r = rSlider ? rSlider.value : 1f;
        float g = gSlider ? gSlider.value : 1f;
        float b = bSlider ? bSlider.value : 1f;

        targetLight.color = new Color(r, g, b);
    }
}
