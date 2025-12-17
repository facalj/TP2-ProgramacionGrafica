using DG.Tweening;
using System;
using System.Collections.Generic;
using UnityEngine;

public class HorizontalCardHolder : MonoBehaviour
{
    [SerializeField] private Card selectedCard;
    [SerializeField] private GameObject slotPrefab;

    [Header("Slots")]
    [SerializeField] private int cardsToSpawn = 7;

    [Header("Fixed Prefabs (index = slot index)")]
    [SerializeField] private List<GameObject> fixedCardPrefabsPerSlot = new();

    [HideInInspector] public List<Card> cards = new();

    [Header("Center Visual Layer")]
    [SerializeField] private RectTransform centeredVisualLayer;

    [Header("Center Visual Settings")]
    [SerializeField] private float centerTweenTime = 0.25f;
    [SerializeField] private Vector3 centeredScale = Vector3.one * 1.1f;

    [Header("Cast Button")]
    [SerializeField] private CastButtonController castButton;

    private Card centeredCard;

    private readonly Dictionary<Card, VisualRestoreData> restoreData = new Dictionary<Card, VisualRestoreData>();

    [Serializable]
    public class CardSceneBinding
    {
        public string cardId;
        public GameObject targetObject;
    }

    [Header("Scene Bindings")]
    [SerializeField] private List<CardSceneBinding> sceneBindings = new();

    private readonly Dictionary<string, GameObject> bindingLookup = new Dictionary<string, GameObject>(StringComparer.OrdinalIgnoreCase);
    private GameObject activeObject;

    private struct VisualRestoreData
    {
        public RectTransform visualRect;
        public Transform originalParent;
        public int originalSiblingIndex;
        public Vector2 originalAnchoredPos;
        public Vector3 originalScale;
    }

    private void Awake()
    {
        bindingLookup.Clear();

        foreach (var binding in sceneBindings)
        {
            if (binding == null) continue;

            string id = binding.cardId == null ? string.Empty : binding.cardId.Trim();
            if (string.IsNullOrWhiteSpace(id)) continue;

            if (binding.targetObject == null) continue;

            if (!bindingLookup.ContainsKey(id))
            {
                bindingLookup.Add(id, binding.targetObject);
                binding.targetObject.SetActive(false);
            }
        }
    }

    private void Start()
    {
        CreateSlots();
        EnsureFixedListSize();
        SpawnFixedCards();
        HookEvents();
    }

    private void CreateSlots()
    {
        for (int i = transform.childCount; i < cardsToSpawn; i++)
        {
            Instantiate(slotPrefab, transform);
        }
    }

    private void EnsureFixedListSize()
    {
        int target = Mathf.Min(cardsToSpawn, transform.childCount);

        while (fixedCardPrefabsPerSlot.Count < target)
            fixedCardPrefabsPerSlot.Add(null);

        if (fixedCardPrefabsPerSlot.Count > target)
            fixedCardPrefabsPerSlot.RemoveRange(target, fixedCardPrefabsPerSlot.Count - target);
    }

    private void SpawnFixedCards()
    {
        ClearSlotsAndCards();

        int slots = Mathf.Min(cardsToSpawn, transform.childCount);

        for (int i = 0; i < slots; i++)
        {
            Transform slot = transform.GetChild(i);
            if (slot == null) continue;

            GameObject prefab = fixedCardPrefabsPerSlot[i];
            if (prefab == null) continue;

            GameObject instanceGO = Instantiate(prefab, slot);
            instanceGO.transform.localPosition = Vector3.zero;
            instanceGO.transform.localRotation = Quaternion.identity;
            instanceGO.transform.localScale = Vector3.one;

            Card card = instanceGO.GetComponentInChildren<Card>(true);
            if (card == null)
            {
                Debug.LogError($"El prefab {prefab.name} no tiene Card (ni en root ni en hijos)");
                continue;
            }

            ForceCardVisualToBeChildOfCard(card);
            cards.Add(card);
        }
    }

    private void ForceCardVisualToBeChildOfCard(Card card)
    {
        if (card == null) return;
        if (card.cardVisual == null) return;

        Transform visualT = card.cardVisual.transform;

        if (visualT.parent != card.transform)
        {
            visualT.SetParent(card.transform, false);
        }

        RectTransform rt = visualT as RectTransform;
        if (rt != null)
        {
            rt.anchorMin = new Vector2(0.5f, 0.5f);
            rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.pivot = new Vector2(0.5f, 0.5f);
            rt.anchoredPosition = Vector2.zero;
            rt.localRotation = Quaternion.identity;
            rt.localScale = Vector3.one;
        }
        else
        {
            visualT.localPosition = Vector3.zero;
            visualT.localRotation = Quaternion.identity;
            visualT.localScale = Vector3.one;
        }
    }

    private void ClearSlotsAndCards()
    {
        cards.Clear();

        for (int i = 0; i < transform.childCount; i++)
        {
            Transform slot = transform.GetChild(i);
            if (slot == null) continue;

            for (int c = slot.childCount - 1; c >= 0; c--)
                Destroy(slot.GetChild(c).gameObject);
        }
    }

    private void HookEvents()
    {
        foreach (Card card in cards)
        {
            if (card == null) continue;

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

    public bool IsCentered(Card card) => centeredCard == card;

    public void CenterCard(Card card)
    {
        Debug.Log($"[HorizontalCardHolder] CenterCard called with card: {card?.name}");

        if (card == null)
            return;

        if (activeObject != null)
        {
            activeObject.SetActive(false);
            activeObject = null;

            if (castButton != null)
                castButton.ClearTarget();
        }

        string id = card.CardId == null ? string.Empty : card.CardId.Trim();

        if (bindingLookup.TryGetValue(id, out var target) && target != null)
        {
            target.SetActive(true);
            activeObject = target;

            Animator animator =
                target.GetComponentInChildren<Animator>(true) ??
                target.GetComponentInParent<Animator>(true);

            Debug.Log($"[HorizontalCardHolder] Target: {target.name} | Animator found: {animator != null}");
            Debug.Log($"[HorizontalCardHolder] castButton ref: {(castButton != null ? castButton.gameObject.name : "NULL")}");

            if (castButton != null)
            {
                if (animator != null) castButton.SetTargetAnimator(animator);
                else castButton.ClearTarget();
            }
            else
            {
                Debug.LogWarning("[HorizontalCardHolder] castButton is NULL. Assign it in the inspector (Canvas CastButtonController).");
            }
        }
        else
        {
            Debug.LogWarning($"No scene binding found for CardId: '{id}'");

            if (castButton != null)
                castButton.ClearTarget();
        }
    }

    public void ClearCenteredCard()
    {
        if (activeObject != null)
        {
            activeObject.SetActive(false);
            activeObject = null;
        }

        if (castButton != null)
            castButton.ClearTarget();
    }

    public void CenterCardVisual(Card card)
    {
        if (card == null) return;
        if (centeredVisualLayer == null) return;
        if (card.cardVisual == null) return;
        if (centeredCard == card) return;

        if (centeredCard != null)
            UncenterCardVisual(centeredCard);

        RectTransform visualRect = card.cardVisual.transform as RectTransform;
        if (visualRect == null) return;

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

        CenterCard(card);
    }

    public void UncenterCardVisual(Card card)
    {
        if (card == null) return;

        if (card.cardVisual != null)
            card.cardVisual.SetCentered(false);

        if (!restoreData.TryGetValue(card, out VisualRestoreData data))
        {
            if (centeredCard == card) centeredCard = null;
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

        ClearCenteredCard();
    }
}
