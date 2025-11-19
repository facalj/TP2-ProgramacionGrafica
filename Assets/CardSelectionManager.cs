using System;
using System.Collections.Generic;
using UnityEngine;

public sealed class CardSelectionManager : MonoBehaviour
{
    [Header("Runtime")]
    [SerializeField] private CardView currentSelected;

    private readonly List<CardView> registeredCards = new List<CardView>();

    public CardView CurrentSelected => currentSelected;

    public event Action<CardView> OnCardSelected;

    internal void RegisterCard(CardView card)
    {
        if (card == null) return;
        if (!registeredCards.Contains(card))
        {
            registeredCards.Add(card);
        }
    }

    internal void UnregisterCard(CardView card)
    {
        if (card == null) return;
        if (registeredCards.Contains(card))
        {
            registeredCards.Remove(card);
        }

        if (currentSelected == card)
        {
            currentSelected.SetSelected(false);
            currentSelected = null;
        }
    }

    public void SelectCard(CardView card)
    {
        if (card == null)
        {
            Debug.LogWarning("CardSelectionManager.SelectCard called with null.");
            return;
        }

        if (!registeredCards.Contains(card))
        {
            Debug.LogWarning("CardSelectionManager: card is not registered.");
            return;
        }

        if (currentSelected == card)
        {
            // Already selected, ignore or toggle if you want that behavior
            return;
        }

        if (currentSelected != null)
        {
            currentSelected.SetSelected(false);
        }

        currentSelected = card;
        currentSelected.SetSelected(true);

        OnCardSelected?.Invoke(currentSelected);
    }
}
