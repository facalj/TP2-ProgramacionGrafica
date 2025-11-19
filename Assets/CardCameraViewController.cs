using UnityEngine;
using Cinemachine;

public sealed class CardCameraViewController : MonoBehaviour
{
    public enum ViewMode
    {
        CardsPreview,
        Focus
    }

    [Header("Cameras")]
    [SerializeField] private CinemachineVirtualCamera cardsPreviewCamera;
    [SerializeField] private CinemachineVirtualCamera focusCamera;

    [Header("Priorities")]
    [SerializeField] private int cardsPreviewPriority = 10;
    [SerializeField] private int focusPriority = 20;

    [Header("Preview Source")]
    [SerializeField] private CardPreviewController previewController;
    [SerializeField] private bool autoAssignLookAtAndFollow = true;

    private ViewMode currentMode = ViewMode.CardsPreview;
    private Transform currentTarget;

    private void Awake()
    {
        if (previewController == null)
        {
            previewController = FindObjectOfType<CardPreviewController>();
        }

        ApplyViewMode(currentMode);
    }

    private void OnEnable()
    {
        if (previewController != null)
        {
            previewController.OnPreviewInstanceChanged += HandlePreviewInstanceChanged;
        }
    }

    private void OnDisable()
    {
        if (previewController != null)
        {
            previewController.OnPreviewInstanceChanged -= HandlePreviewInstanceChanged;
        }
    }

    private void HandlePreviewInstanceChanged(Transform newTarget)
    {
        currentTarget = newTarget;

        if (!autoAssignLookAtAndFollow) return;

        if (focusCamera != null)
        {
            focusCamera.Follow = currentTarget;
            focusCamera.LookAt = currentTarget;
        }

        // Si quisieras que la cámara de preview también siga algo
        // podrías setear Follow/LookAt aquí.
    }

    public void ToggleViewMode()
    {
        if (currentMode == ViewMode.CardsPreview)
        {
            SetViewMode(ViewMode.Focus);
        }
        else
        {
            SetViewMode(ViewMode.CardsPreview);
        }
    }

    public void SetViewMode(ViewMode newMode)
    {
        currentMode = newMode;
        ApplyViewMode(currentMode);
    }

    private void ApplyViewMode(ViewMode mode)
    {
        if (cardsPreviewCamera == null || focusCamera == null)
        {
            Debug.LogWarning("CardCameraViewController: Cameras are not assigned.");
            return;
        }

        switch (mode)
        {
            case ViewMode.CardsPreview:
                cardsPreviewCamera.Priority = cardsPreviewPriority;
                focusCamera.Priority = cardsPreviewPriority - 1;
                break;

            case ViewMode.Focus:
                cardsPreviewCamera.Priority = focusPriority - 1;
                focusCamera.Priority = focusPriority;
                break;
        }
    }
}
