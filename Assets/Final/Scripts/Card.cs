using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using System.Collections;
using UnityEngine.UI;

public class Card : MonoBehaviour, IDragHandler, IBeginDragHandler, IEndDragHandler, IPointerEnterHandler, IPointerExitHandler, IPointerUpHandler, IPointerDownHandler
{
    private Canvas canvas;
    private Image imageComponent;
    [SerializeField] private bool instantiateVisual = true;
    private VisualCardsHandler visualHandler;
    private Vector3 offset;

    [Header("Movement")]
    [SerializeField] private float moveSpeedLimit = 50;

    [Header("Selection")]
    public bool selected;
    public float selectionOffset = 50;
    private float pointerDownTime;
    private float pointerUpTime;

    [Header("Visual")]
    [SerializeField] private GameObject cardVisualPrefab;
    [HideInInspector] public CardVisual cardVisual;

    [Header("States")]
    public bool isHovering;
    public bool isDragging;
    [HideInInspector] public bool wasDragged;

    [Header("Events")]
    [HideInInspector] public UnityEvent<Card> PointerEnterEvent;
    [HideInInspector] public UnityEvent<Card> PointerExitEvent;
    [HideInInspector] public UnityEvent<Card, bool> PointerUpEvent;
    [HideInInspector] public UnityEvent<Card> PointerDownEvent;
    [HideInInspector] public UnityEvent<Card> BeginDragEvent;
    [HideInInspector] public UnityEvent<Card> EndDragEvent;
    [HideInInspector] public UnityEvent<Card, bool> SelectEvent;

    void Start()
    {
        canvas = GetComponentInParent<Canvas>();
        imageComponent = GetComponent<Image>();

        if (!instantiateVisual)
            return;

        visualHandler = FindFirstObjectByType<VisualCardsHandler>();
        cardVisual = Instantiate(cardVisualPrefab, visualHandler ? visualHandler.transform : canvas.transform).GetComponent<CardVisual>();
        cardVisual.Initialize(this);
    }

    void Update()
    {
        ClampPosition();

        if (!isDragging)
            return;

        // Distancia en Z desde la cámara hasta el plano donde se mueven las cartas
        float zPlane = Mathf.Abs(Camera.main.transform.position.z);

        // Mouse en coordenadas de mundo, en el mismo plano Z que la carta
        Vector3 mouseWorld = Camera.main.ScreenToWorldPoint(
            new Vector3(Input.mousePosition.x, Input.mousePosition.y, zPlane)
        );

        Vector2 targetPosition = (Vector2)mouseWorld - (Vector2)offset;
        Vector2 direction = (targetPosition - (Vector2)transform.position).normalized;
        float distance = Vector2.Distance(transform.position, targetPosition);

        Vector2 velocity = direction * Mathf.Min(moveSpeedLimit, distance / Time.deltaTime);

        // Movimiento en mundo (mantiene bien el orden y el Swap)
        transform.Translate(velocity * Time.deltaTime, Space.World);
    }

    void ClampPosition()
    {
        float zPlane = Mathf.Abs(Camera.main.transform.position.z);

        Vector3 topRight = Camera.main.ScreenToWorldPoint(
            new Vector3(Screen.width, Screen.height, zPlane)
        );
        Vector3 bottomLeft = Camera.main.ScreenToWorldPoint(
            new Vector3(0f, 0f, zPlane)
        );

        Vector3 pos = transform.position;
        pos.x = Mathf.Clamp(pos.x, bottomLeft.x, topRight.x);
        pos.y = Mathf.Clamp(pos.y, bottomLeft.y, topRight.y);

        transform.position = new Vector3(pos.x, pos.y, transform.position.z);
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        BeginDragEvent.Invoke(this);

        float zPlane = Mathf.Abs(Camera.main.transform.position.z);
        Vector3 mouseWorld = Camera.main.ScreenToWorldPoint(
            new Vector3(eventData.position.x, eventData.position.y, zPlane)
        );

        offset = mouseWorld - transform.position;

        isDragging = true;
        canvas.GetComponent<GraphicRaycaster>().enabled = false;
        imageComponent.raycastTarget = false;

        wasDragged = true;
    }


    public void OnDrag(PointerEventData eventData)
    {
    }

    public void OnEndDrag(PointerEventData eventData)
    {
        EndDragEvent.Invoke(this);
        isDragging = false;
        canvas.GetComponent<GraphicRaycaster>().enabled = true;
        imageComponent.raycastTarget = true;

        StartCoroutine(FrameWait());

        IEnumerator FrameWait()
        {
            yield return new WaitForEndOfFrame();
            wasDragged = false;
        }
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        PointerEnterEvent.Invoke(this);
        isHovering = true;
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        PointerExitEvent.Invoke(this);
        isHovering = false;
    }


    public void OnPointerDown(PointerEventData eventData)
    {
        if (eventData.button != PointerEventData.InputButton.Left)
            return;

        PointerDownEvent.Invoke(this);
        pointerDownTime = Time.time;
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        if (eventData.button != PointerEventData.InputButton.Left)
            return;

        pointerUpTime = Time.time;

        PointerUpEvent.Invoke(this, pointerUpTime - pointerDownTime > .2f);

        if (pointerUpTime - pointerDownTime > .2f)
            return;

        if (wasDragged)
            return;

        selected = !selected;
        SelectEvent.Invoke(this, selected);

        if (selected)
            transform.localPosition += (cardVisual.transform.up * selectionOffset);
        else
            transform.localPosition = Vector3.zero;
    }

    public void Deselect()
    {
        if (selected)
        {
            selected = false;
            if (selected)
                transform.localPosition += (cardVisual.transform.up * 50);
            else
                transform.localPosition = Vector3.zero;
        }
    }


    public int SiblingAmount()
    {
        return transform.parent.CompareTag("Slot") ? transform.parent.parent.childCount - 1 : 0;
    }

    public int ParentIndex()
    {
        return transform.parent.CompareTag("Slot") ? transform.parent.GetSiblingIndex() : 0;
    }

    public float NormalizedPosition()
    {
        return transform.parent.CompareTag("Slot") ? ExtensionMethods.Remap((float)ParentIndex(), 0, (float)(transform.parent.parent.childCount - 1), 0, 1) : 0;
    }

    private void OnDestroy()
    {
        if (cardVisual != null)
            Destroy(cardVisual.gameObject);
    }
}