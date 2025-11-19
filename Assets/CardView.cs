using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using TMPro; // Si no usás TextMeshPro, cambialo a UnityEngine.UI.Text

[RequireComponent(typeof(Button))]
public class CardView : MonoBehaviour, IPointerClickHandler
{
    [Header("Data")]
    [SerializeField] private CardDefinition cardDefinition;

    [Header("Dependencies")]
    [SerializeField] private CardSelectionManager selectionManager;

    [Header("UI References")]
    [SerializeField] private Image iconImage;
    [SerializeField] private TextMeshProUGUI nameText;
    [SerializeField] private TextMeshProUGUI descriptionText;
    [SerializeField] private GameObject selectedHighlight;

    private Button _button;

    public CardDefinition Definition => cardDefinition;

    private void Awake()
    {
        _button = GetComponent<Button>();

        // Fallback if selectionManager is not set in Inspector
        if (selectionManager == null)
        {
            selectionManager = FindObjectOfType<CardSelectionManager>();
        }

        RefreshVisuals();
    }

    private void OnEnable()
    {
        if (selectionManager != null)
        {
            selectionManager.RegisterCard(this);
        }
    }

    private void OnDisable()
    {
        if (selectionManager != null)
        {
            selectionManager.UnregisterCard(this);
        }
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        if (selectionManager == null)
        {
            Debug.LogWarning("CardView: selectionManager is not assigned.");
            return;
        }

        selectionManager.SelectCard(this);
    }

    public void SetSelected(bool isSelected)
    {
        if (selectedHighlight != null)
        {
            selectedHighlight.SetActive(isSelected);
        }
    }

    public void SetDefinition(CardDefinition definition)
    {
        cardDefinition = definition;
        RefreshVisuals();
    }

    private void RefreshVisuals()
    {
        if (cardDefinition == null)
        {
            if (iconImage != null) iconImage.enabled = false;
            if (nameText != null) nameText.text = string.Empty;
            if (descriptionText != null) descriptionText.text = string.Empty;
            return;
        }

        if (iconImage != null)
        {
            iconImage.sprite = cardDefinition.Icon;
            iconImage.enabled = cardDefinition.Icon != null;
        }

        if (nameText != null)
        {
            nameText.text = cardDefinition.DisplayName;
        }

        if (descriptionText != null)
        {
            descriptionText.text = cardDefinition.Description;
        }
    }
}
