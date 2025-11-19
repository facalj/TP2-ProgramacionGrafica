using System;
using UnityEngine;

public sealed class CardPreviewController : MonoBehaviour
{
    [Header("Dependencies")]
    [SerializeField] private CardSelectionManager selectionManager;

    [Tooltip("Where the 3D model will be instantiated. If null, this GameObject's transform will be used.")]
    [SerializeField] private Transform previewAnchor;

    [Header("Settings")]
    [SerializeField] private bool destroyPreviousOnChange = true;

    private GameObject currentInstance;

    public Transform CurrentInstanceTransform => currentInstance != null ? currentInstance.transform : null;

    public event Action<Transform> OnPreviewInstanceChanged;

    private void Awake()
    {
        if (selectionManager == null)
        {
            selectionManager = FindObjectOfType<CardSelectionManager>();
        }

        if (previewAnchor == null)
        {
            previewAnchor = transform;
        }
    }

    private void OnEnable()
    {
        if (selectionManager != null)
        {
            selectionManager.OnCardSelected += HandleCardSelected;
        }
    }

    private void OnDisable()
    {
        if (selectionManager != null)
        {
            selectionManager.OnCardSelected -= HandleCardSelected;
        }
    }

    private void HandleCardSelected(CardView cardView)
    {
        if (cardView == null)
        {
            ClearCurrentInstance();
            return;
        }

        var definition = cardView.Definition;
        if (definition == null || definition.ModelPrefab == null)
        {
            ClearCurrentInstance();
            return;
        }

        ReplaceModel(definition.ModelPrefab);
    }

    private void ReplaceModel(GameObject prefab)
    {
        ClearCurrentInstance();

        if (prefab == null) return;

        currentInstance = Instantiate(prefab, previewAnchor);
        currentInstance.transform.localPosition = Vector3.zero;
        currentInstance.transform.localRotation = Quaternion.identity;
        currentInstance.transform.localScale = Vector3.one;

        OnPreviewInstanceChanged?.Invoke(currentInstance.transform);
    }

    public void ClearCurrentInstance()
    {
        if (currentInstance != null)
        {
            if (destroyPreviousOnChange)
            {
                Destroy(currentInstance);
            }
            else
            {
                currentInstance.SetActive(false);
            }

            currentInstance = null;
        }

        OnPreviewInstanceChanged?.Invoke(null);
    }
}
