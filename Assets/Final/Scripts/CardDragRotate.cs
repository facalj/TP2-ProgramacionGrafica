using UnityEngine;
using UnityEngine.EventSystems;

[RequireComponent(typeof(RectTransform))]
public class CardDragRotate : MonoBehaviour, IBeginDragHandler, IDragHandler, IEndDragHandler
{
    [Header("Dependencies")]
    [SerializeField] private Canvas parentCanvas;

    [Header("Drag Settings")]
    [SerializeField] private bool canDrag = true;
    [SerializeField] private bool canRotate = true;

    [SerializeField] private float rotationSpeed = 0.3f;

    private RectTransform _rectTransform;
    private Vector3 _originalPosition;
    private Quaternion _originalRotation;
    private PointerEventData.InputButton _activeButton;

    private void Awake()
    {
        _rectTransform = GetComponent<RectTransform>();

        if (parentCanvas == null)
        {
            parentCanvas = GetComponentInParent<Canvas>();
        }

        _originalPosition = _rectTransform.anchoredPosition3D;
        _originalRotation = _rectTransform.localRotation;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        _activeButton = eventData.button;
    }

    public void OnDrag(PointerEventData eventData)
    {
        if (parentCanvas == null)
            return;

        if (_activeButton == PointerEventData.InputButton.Left && canDrag)
        {
            Vector2 delta = eventData.delta / parentCanvas.scaleFactor;
            _rectTransform.anchoredPosition += delta;
        }
        else if (_activeButton == PointerEventData.InputButton.Right && canRotate)
        {
            float deltaX = eventData.delta.x;
            float angle = -deltaX * rotationSpeed;
            _rectTransform.Rotate(0f, 0f, angle, Space.Self);
        }
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        _activeButton = PointerEventData.InputButton.Left;
    }

    public void ResetTransform()
    {
        _rectTransform.anchoredPosition3D = _originalPosition;
        _rectTransform.localRotation = _originalRotation;
    }
}
