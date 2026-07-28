package handler

import (
	"testing"

	"quickdesk/signaling/internal/service"
)

func TestRevokedFamilyIDScopesFamilyBreak(t *testing.T) {
	event := service.Event{
		Type: service.EventSessionRevoked,
		Data: map[string]interface{}{
			"family_id": "family-a",
			"reason":    "family_break",
		},
	}

	if got := revokedFamilyID(event); got != "family-a" {
		t.Fatalf("revokedFamilyID() = %q, want family-a", got)
	}
}

func TestRevokedFamilyIDKeepsGlobalRevocationGlobal(t *testing.T) {
	event := service.Event{
		Type: service.EventSessionRevoked,
		Data: map[string]interface{}{"reason": "password_reset"},
	}

	if got := revokedFamilyID(event); got != "" {
		t.Fatalf("revokedFamilyID() = %q, want empty family for global revocation", got)
	}
}

func TestFilterEventsForFamilyDropsOtherFamilyRevocation(t *testing.T) {
	events := []service.Event{
		{Type: service.EventDeviceOnlineChanged, ServerRev: 10},
		{Type: service.EventSessionRevoked, ServerRev: 11, Data: map[string]interface{}{
			"family_id": "family-a",
			"reason":    "family_break",
		}},
		{Type: service.EventSessionRevoked, ServerRev: 12, Data: map[string]interface{}{
			"family_id": "family-b",
			"reason":    "family_break",
		}},
		{Type: service.EventSessionRevoked, ServerRev: 13, Data: map[string]interface{}{
			"reason": "password_reset",
		}},
	}

	visible, hidden := filterEventsForFamily(events, "family-b")
	if hidden != 1 {
		t.Fatalf("hidden = %d, want 1", hidden)
	}
	if len(visible) != 3 {
		t.Fatalf("len(visible) = %d, want 3", len(visible))
	}
	if visible[0].ServerRev != 10 || visible[1].ServerRev != 12 || visible[2].ServerRev != 13 {
		t.Fatalf("visible revs = [%d %d %d], want [10 12 13]",
			visible[0].ServerRev, visible[1].ServerRev, visible[2].ServerRev)
	}
}

func TestFilterEventsForFamilyKeepsGlobalRevocation(t *testing.T) {
	events := []service.Event{{
		Type:      service.EventSessionRevoked,
		ServerRev: 20,
		Data:      map[string]interface{}{"reason": "admin_forced"},
	}}

	visible, hidden := filterEventsForFamily(events, "family-b")
	if hidden != 0 {
		t.Fatalf("hidden = %d, want 0", hidden)
	}
	if len(visible) != 1 || visible[0].ServerRev != 20 {
		t.Fatalf("visible = %#v, want global revocation", visible)
	}
}
