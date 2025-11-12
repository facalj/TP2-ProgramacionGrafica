using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

[DisallowMultipleComponent]
public class LightSliderController : MonoBehaviour
{
    [Header("Luz Direccional a controlar")]
    public Light targetLight;

    [Header("Sliders de Color (valores de 0 a 1)")]
    public Slider rSlider;
    public Slider gSlider;
    public Slider bSlider;
    public Slider aSlider; // opcional, sin uso en Light.color

    [Header("Rotación en X (grados)")]
    public Slider xRotationSlider;
    public float rotationMin = 0f;
    public float rotationMax = 180f;

    private UnityAction<float> _rCb, _gCb, _bCb, _aCb, _rotCb;
    private bool _colorHooked = false;
    private bool _rotationHooked = false;

    private void OnEnable()
    {
        HookUI(true);
        InitColorSlidersFromCurrent();
        InitRotationSliderFromCurrent();
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

        // Rotación
        if (!_rotationHooked && on && xRotationSlider)
        {
            _rotCb = _ => ApplyRotationFromUI();
            xRotationSlider.onValueChanged.AddListener(_rotCb);
            TryDisableNavigation(xRotationSlider);
            _rotationHooked = true;
        }
        else if (_rotationHooked && !on && xRotationSlider)
        {
            xRotationSlider.onValueChanged.RemoveListener(_rotCb);
            _rotationHooked = false;
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

    private void InitRotationSliderFromCurrent()
    {
        if (targetLight == null || xRotationSlider == null) return;

        if (xRotationSlider.minValue == 0f && xRotationSlider.maxValue == 1f)
        {
            xRotationSlider.minValue = rotationMin;
            xRotationSlider.maxValue = rotationMax;
        }

        float currentX = targetLight.transform.rotation.eulerAngles.x;
        currentX = Mathf.Clamp(currentX, rotationMin, rotationMax);

        xRotationSlider.SetValueWithoutNotify(currentX);
    }

    private void ApplyRotationFromUI()
    {
        if (targetLight == null || xRotationSlider == null) return;

        float xRotation = xRotationSlider.value;

        targetLight.transform.localRotation = Quaternion.Euler(xRotation, 0f, 0f);
    }
}
