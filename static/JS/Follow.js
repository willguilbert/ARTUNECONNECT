/*
Fonction qui effectue un AJAX call au endpoint toggle_follow et pense en query param le artisteID,
pour que le endpoint handle l'insert ou le delete dans la bd à la bonne place. La variable isFollowing
ici réfère au state du bouton, si il est en mode s'abonner ou se désabonner. Tout dependant le mode, on set le bouton
d'une couleur, et lors on décide de la méthod POST ou DELETE à envoyer au endpoint.
 */
document.addEventListener('DOMContentLoaded', function() {
    var followButton = document.querySelector('.follow-btn');
    var artisteId = followButton.getAttribute('data-id');
    /*
    Fonction qui deal avec l'update de la couleur et du text du bouton "follow".
    @param {Boolean} isFollowing
     */
    function updateFollowButton(isFollowing) {
        followButton.textContent = isFollowing ? 'Se désabonner' : "S'abonner";
        followButton.classList.toggle('btn-danger', isFollowing);
        followButton.classList.toggle('btn-primary', !isFollowing);
    }
     fetch(`/follow?artiste_id=${artisteId}`)
    .then(response => response.json())
    .then(data => {
        if(data.error) {
            console.error('Error:', data.error);
        } else {
            updateFollowButton(data.follows);
        }
    })
    .catch(error => {
        console.error('Error:', error);
    });

    /*
    Fonction qui envoie le AJAX call au endpoint follow selon la methode DELETE ou POST qui est decider selon
    le boolean isFollowing.
    @param event
     */
    function toggleFollow(event) {
        event.preventDefault();
        var isFollowing = followButton.textContent.trim() === 'Se désabonner';
        var method = isFollowing ? 'DELETE' : 'POST';

        fetch(`/follow?artiste_id=${artisteId}`, { method: method })
        .then(response => response.json())
        .then(data => {
            if(data.error) {
                console.error('Error:', data.error);
            } else {
                updateFollowButton(!isFollowing);
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
    }
    followButton.addEventListener('click', toggleFollow);
});