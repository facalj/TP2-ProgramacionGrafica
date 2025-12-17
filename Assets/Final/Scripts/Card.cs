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

    [Header("Linked GameObject")]
    [SerializeField] private GameObject linkedGameObject;

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

    private void Awake()
    {
        if (PointerEnterEvent == null) PointerEnterEvent = new UnityEngine.Events.UnityEvent<Card>();
        if (PointerExitEvent == null) PointerExitEvent = new UnityEngine.Events.UnityEvent<Card>();
        if (PointerUpEvent == null) PointerUpEvent = new UnityEngine.Events.UnityEvent<Card, bool>();
        if (PointerDownEvent == null) PointerDownEvent = new UnityEngine.Events.UnityEvent<Card>();
        if (BeginDragEvent == null) BeginDragEvent = new UnityEngine.Events.UnityEvent<Card>();
        if (EndDragEvent == null) EndDragEvent = new UnityEngine.Events.UnityEvent<Card>();
        if (SelectEvent == null) SelectEvent = new UnityEngine.Events.UnityEvent<Card, bool>();
    }

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
        if (!isDragging)
            return;

        float zPlane = Mathf.Abs(Camera.main.transform.position.z);
        Vector3 mouseWorld = Camera.main.ScreenToWorldPoint(
            new Vector3(Input.mousePosition.x, Input.mousePosition.y, zPlane)
        );

        Vector2 targetPosition = (Vector2)mouseWorld + (Vector2)offset;
        Vector2 delta = targetPosition - (Vector2)transform.position;
        float distance = delta.magnitude;

        if (distance > 0.001f)
        {
            Vector2 direction = delta / distance;
            Vector2 velocity = direction * Mathf.Min(moveSpeedLimit, distance / Time.deltaTime);
            transform.Translate(velocity * Time.deltaTime, Space.World);
        }
    }

    public void ActivateLinkedObject()
    {
        if (linkedGameObject != null)
            linkedGameObject.SetActive(true);
    }

    public void DeactivateLinkedObject()
    {
        if (linkedGameObject != null)
            linkedGameObject.SetActive(false);
    }
    void ClampToCanvasBounds()
    {
        RectTransform canvasRect = canvas.transform as RectTransform;
        RectTransform cardRect = transform as RectTransform;

        Vector3 pos = cardRect.localPosition;

        float halfWidth = canvasRect.rect.width / 2f - cardRect.rect.width / 2f;
        float halfHeight = canvasRect.rect.height / 2f - cardRect.rect.height / 2f;

        pos.x = Mathf.Clamp(pos.x, -halfWidth, halfWidth);
        pos.y = Mathf.Clamp(pos.y, -halfHeight, halfHeight);

        cardRect.localPosition = pos;
    }

    public void OnBeginDrag(PointerEventData eventData)
    {
        BeginDragEvent.Invoke(this);

        float zPlane = Mathf.Abs(Camera.main.transform.position.z);
        Vector3 mouseWorld = Camera.main.ScreenToWorldPoint(
            new Vector3(eventData.position.x, eventData.position.y, zPlane)
        );

        // IMPORTANTE: offset = card - mouse (esto arregla el movimiento invertido)
        offset = (Vector2)transform.position - (Vector2)mouseWorld;

        isDragging = true;
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
        //canvas.GetComponent<GraphicRaycaster>().enabled = true;
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

        if (PointerUpEvent != null)
            PointerUpEvent.Invoke(this, pointerUpTime - pointerDownTime > 0.2f);

        if (pointerUpTime - pointerDownTime > 0.2f)
            return;

        if (wasDragged)
            return;

        HorizontalCardHolder holder = GetComponentInParent<HorizontalCardHolder>();
        if (holder == null)
            return;

        if (eventData.clickCount >= 2)
        {
            selected = false;
            if (SelectEvent != null)
                SelectEvent.Invoke(this, false);

            holder.UncenterCardVisual(this);
            return;
        }

        selected = true;
        if (SelectEvent != null)
            SelectEvent.Invoke(this, true);

        holder.CenterCardVisual(this);
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