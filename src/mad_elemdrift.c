#include "madx.h"

static struct element*
get_drift(double length)
  /* makes a drift space with the required length */
{
  const double tol = 1e-12; // length tolerance for sharing implicit drift
  struct element *p, *bt;
  struct command* clone;
  char key[NAME_L];

  for (int i = 0; i < drift_list->curr; i++) {
    p = drift_list->elem[i];
    if (fabs(p->length - length) < tol) return p;
  }

  sprintf(key, "drift_%d", drift_list->curr);
  bt = find_element("drift", base_type_list);
  clone = clone_command(bt->def);
  store_comm_par_value("l", length, clone);
  p = make_element(key, "drift", clone, 0);
  add_to_el_list(&p, 1, drift_list, 0);
  return p;
}

int
add_drifts(struct node* c_node, struct node* end)
{
  const double tol = 1e-6;
  int cnt = 0;

  if (!c_node) return cnt;

  for (; c_node != end && c_node->next; c_node = c_node->next, cnt++) {
    double drift_beg = c_node->position + c_node->length / 2;
    double drift_end = c_node->next->position - c_node->next->length / 2;
    double drift_len = drift_end-drift_beg;

    if (drift_len < -tol) {
      // implicit drift with negative length
      char buf[256];
      sprintf(buf, " %s and %s, length %e", c_node->name, c_node->next->name, drift_len);
      fatal_error("negative drift between elements", buf);
    }
    else if (drift_len > tol) {
      // create or share 'long-enough' implicit drift
      struct element *drift = get_drift(drift_len);
      struct node *drift_node = new_elem_node(drift, 0);
      link_in_front(drift_node, c_node->next);
      drift_node->position = drift_beg + drift_len / 2;
      cnt++;
    }
    else 
      // length in [-tol, tol], nothing to do (no drift inserted)
      ;
  }

  return cnt;
}

