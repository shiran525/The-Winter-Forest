using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyScript : MonoBehaviour
{
    public GameObject player;
    Animator animator;
    Animator ani;
   
    // Start is called before the first frame update
    void Start()
    {
         animator = GetComponent<Animator>();

    }

    // Update is called once per frame
    void Update()
    {
        float distance = Vector3.Distance(player.transform.position, transform.position);
        animator.SetFloat("distance", distance);
        if (distance < 5)
        {
            animator.SetBool("attack", true);
        }
    }

    //attacking enemy doesnt work 

    void OnCollisionEnter(Collision collisionInfo)
    {
        ani = player.GetComponent<Animator>();


        if (collisionInfo.gameObject.tag == "arthur" && !ani.GetBool("attack"))
        {
            //  SceneManager.LoadScene(0);
            Debug.Log("arthur dead");
            ani.SetBool("dead",true);
        }

        if (collisionInfo.gameObject.tag == "arthur" && ani.GetBool("attack"))
        {
            Destroy(transform.gameObject);
        }

    }
}
