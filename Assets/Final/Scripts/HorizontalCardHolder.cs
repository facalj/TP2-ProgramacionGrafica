using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using DG.Tweening;

public class HorizontalCardHolder : MonoBehaviour
{
    [SerializeField] private Card selectedCard;

    [SerializeField] private GameObject slotPrefab;

    [Header("Spawn Settings")]
    [SerializeField] private int cardsToSpawn = 7;
    public List<Card> cards = new List<Card>();

    [Header("Center Visual Layer")]
    [SerializeField] private RectTransform centeredVisualLayer;

    [Header("Center Visual Settings")]
    [SerializeField] private float centerTweenTime = 0.25f;
    [SerializeField] private Vector3 centeredScale = Vector3.one * 1.1f;

    private Card centeredCard;

    private readonly Dictionary<Card, VisualRestoreData> restoreData = new Dictionary<Card, VisualRestoreData>();

    private struct VisualRestoreData
    {
        public RectTransform visualRect;
        public Transform originalParent;
        public int originalSiblingIndex;
        public Vector2 originalAnchoredPos;
        public Vector3 originalScale;
    }

    private void Start()
    {
        CreateSlots();
        CollectCards();
        HookEvents();
    }

    private void CreateSlots()
    {
        for (int i = transform.childCount; i < cardsToSpawn; i++)
        {
            Instantiate(slotPrefab, transform);
        }
    }

    private void CollectCards()
    {
        cards = GetComponentsInChildren<Card>(true).ToList();
    }

    private void HookEvents()
    {
        foreach (Card card in cards)
        {
            card.BeginDragEvent.AddListener(BeginDrag);
            card.EndDragEvent.AddListener(EndDrag);
        }
    }

    private void BeginDrag(Card card)
    {
        selectedCard = card;
    }

    private void EndDrag(Card card)
    {
        selectedCard = null;
    }

    public bool IsCentered(Card card)
    {
        return centeredCard == card;
    }

    public void CenterCardVisual(Card card)
    {
        if (card == null)
            return;

        if (centeredVisualLayer == null)
            return;

        if (card.cardVisual == null)
            return;

        if (centeredCard == card)
            return;

        if (centeredCard != null)
            UncenterCardVisual(centeredCard);

        RectTransform visualRect = card.cardVisual.transform as RectTransform;
        if (visualRect == null)
            return;

        VisualRestoreData data = new VisualRestoreData
        {
            visualRect = visualRect,
            originalParent = visualRect.parent,
            originalSiblingIndex = visualRect.GetSiblingIndex(),
            originalAnchoredPos = visualRect.anchoredPosition,
            originalScale = visualRect.localScale
        };

        restoreData[card] = data;

        visualRect.DOKill();

        card.cardVisual.SetCentered(true);

        visualRect.SetParent(centeredVisualLayer, false);
        visualRect.SetAsLastSibling();

        visualRect.anchorMin = new Vector2(0.5f, 0.5f);
        visualRect.anchorMax = new Vector2(0.5f, 0.5f);
        visualRect.pivot = new Vector2(0.5f, 0.5f);

        visualRect.anchoredPosition = Vector2.zero;

        visualRect.DOAnchorPos(Vector2.zero, centerTweenTime).SetEase(Ease.OutBack);
        visualRect.DOScale(centeredScale, centerTweenTime).SetEase(Ease.OutBack);

        centeredCard = card;

    }

    public void UncenterCardVisual(Card card)
    {
        if (card == null)
            return;

        if (card.cardVisual != null)
            card.cardVisual.SetCentered(false);


        if (!restoreData.TryGetValue(card, out VisualRestoreData data))
        {
            if (centeredCard == card)
                centeredCard = null;

            return;
        }

        RectTransform visualRect = data.visualRect;
        if (visualRect == null)
        {
            restoreData.Remove(card);
            if (centeredCard == card) centeredCard = null;
            return;
        }

        visualRect.DOKill();

        visualRect.DOScale(data.originalScale, centerTweenTime).SetEase(Ease.OutBack);

        visualRect.DOAnchorPos(data.originalAnchoredPos, centerTweenTime)
            .SetEase(Ease.OutBack)
            .OnComplete(() =>
            {
                if (visualRect == null) return;

                visualRect.SetParent(data.originalParent, false);
                visualRect.SetSiblingIndex(data.originalSiblingIndex);
                visualRect.anchoredPosition = data.originalAnchoredPos;
                visualRect.localScale = data.originalScale;
            });

        restoreData.Remove(card);

        if (centeredCard == card)
            centeredCard = null;
    }
}
